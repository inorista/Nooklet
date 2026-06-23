//
//  ChatViewModel.swift
//  edgellmtest
//
//  Created by Sidhant Srikumar on 5/25/25.
//

import Combine
import Foundation
import RealmSwift
import SwiftUI
import UIKit

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isModelLoading: Bool = true
    @Published var isThinking: Bool = false

    @Published var selectedUIImage: UIImage?

    /// Stores a critical error message if model initialization fails
    @Published public var criticalError: String?
    @Published public var isApplyingSettings: Bool = false

    // MARK: - Model Switching State
    /// List of models found in the app bundle.
    @Published public var availableModels: [ModelIdentifier] = []
    /// Persisted preference for the selected model identifier's raw value.
    @AppStorage("selectedModelIdentifierRawValue") private
        var selectedModelIdentifierRawValue: String = ModelIdentifier.gemma2B
            .rawValue  // Default preference to 2B

    /// The currently selected model identifier, derived from `@AppStorage`.
    public var selectedModelIdentifier: ModelIdentifier {
        get {
            ModelIdentifier(rawValue: selectedModelIdentifierRawValue)
                ?? .gemma2B
        }
        set { selectedModelIdentifierRawValue = newValue.rawValue }
    }

    private var currentOnDeviceModel: OnDeviceModel?
    private var currentChat: Chat?
    private var generationTask: Task<Void, Error>?

    // MARK: - Realm State
    public var currentSession: ChatSessionEntity?
    private var needsContextInjection: Bool = false

    init() {
        Task {
            self.availableModels = ModelIdentifier.availableInBundle()

            if availableModels.isEmpty {
                let noModelsErrorMessage =
                    "Critical Error: No LLM models found in the app bundle. Please ensure model files (e.g., *.task) are correctly added to the project."
                NSLog(noModelsErrorMessage)
                criticalError = noModelsErrorMessage
                isModelLoading = false
                return
            }

            var initialModelToLoad = ModelIdentifier.gemma2B

            // Determine the actual initial model based on availability and preference
            let preferredModelFromStorage = ModelIdentifier(
                rawValue: selectedModelIdentifierRawValue
            )
            if let prefModel = preferredModelFromStorage,
                availableModels.contains(prefModel)
            {
                initialModelToLoad = prefModel
            } else if availableModels.contains(.gemma2B) {
                initialModelToLoad = .gemma2B
            } else if let firstAvailable = availableModels.first {
                initialModelToLoad = firstAvailable
            }

            self.selectedModelIdentifier = initialModelToLoad

            await loadAndInitializeModel(identifier: initialModelToLoad)
        }
    }

    /// Loads and initializes the specified LLM model and chat session.
    /// This is an async operation that updates loading states and messages.
    private func loadAndInitializeModel(identifier: ModelIdentifier) async {
        isModelLoading = true
        messages.removeAll()
        criticalError = nil

        messages.append(
            ChatMessage(
                content:
                    "Initializing \(identifier.displayName)... Please wait.",
                isUserMessage: false
            )
        )

        do {
            NSLog("Attempting to load model: \(identifier.displayName)")
            currentOnDeviceModel = try await OnDeviceModel(
                modelIdentifier: identifier
            )
            currentChat = try await Chat(
                model: currentOnDeviceModel!,
                topK: 64,
                topP: 0.95,
                temperature: 1.0,
            )

            messages.removeAll()
            messages.append(
                ChatMessage(
                    content:
                        "Model \(identifier.displayName) loaded. Hello! How can I help?",
                    isUserMessage: false
                )
            )

        } catch {
            let loadErrorMessage =
                "Error initializing \(identifier.displayName): \(error.localizedDescription)"
            NSLog(loadErrorMessage)
            messages.removeAll()
            messages.append(
                ChatMessage(content: loadErrorMessage, isUserMessage: false)
            )
            criticalError = loadErrorMessage
        }

        isModelLoading = false
        isThinking = false
        clearSelectedImage()
        inputText = ""
    }

    // MARK: - Realm Integration
    public func loadInitialData(sessionId: UUID?) async{
        if let id = sessionId {
            do {
                if let session = try await RealmService.shared.getChatSession(by: id)
                {
                    loadSession(session)
                    return
                }
            } catch {
                print("Error finding session by ID: \(error)")
            }
        } else {
            createNewChatSession()
        }
    }

    public func loadSession(_ session: ChatSessionEntity) {
        self.currentSession = session

        let sortedEntities = session.messages.sorted(by: {
            $0.timestamp < $1.timestamp
        })
        self.messages = sortedEntities.map { entity in
            ChatMessage(
                id: entity.id,
                content: entity.content,
                isUserMessage: entity.isUserMessage,
                timestamp: entity.timestamp,
                uiImage: entity.uiImage
            )
        }

        Task {
            try? await self.currentChat?.resetConversation()
        }
        self.needsContextInjection = true
    }

    public func createNewChatSession() {
        do {
            let newSession = try RealmService.shared.createNewChatSession()
            self.currentSession = newSession
            self.messages = []

            Task {
                try? await self.currentChat?.resetConversation()
            }
        } catch {
            print("Error creating new session: \(error)")
        }
    }

    private func saveMessageToDatabase(_ message: ChatMessage) {
        guard let session = currentSession else { return }

        do {
            let entity = ChatMessageEntity.fromModel(message)
            try RealmService.shared.saveMessage(entity, to: session)
        } catch {
            print("Error saving message: \(error)")
        }
    }

    // Send a message from the user to the LLM
    func sendMessage(_ text: String) {
        let imageToSend = selectedUIImage

        guard
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || imageToSend != nil
        else { return }

        let userMessage = ChatMessage(
            content: text,
            isUserMessage: true,
            uiImage: imageToSend
        )
        messages.append(userMessage)
        saveMessageToDatabase(userMessage)

        inputText = ""
        clearSelectedImage()

        generationTask?.cancel()

        generationTask = Task {
            defer {
                Task { @MainActor in
                    self.isThinking = false
                    self.generationTask = nil
                }
            }
            do {
                try Task.checkCancellation()

                guard let chat = currentChat else {
                    let chatNotReadyMessage =
                        "Chat session is not ready. The selected model might be loading or failed to initialize."
                    NSLog(chatNotReadyMessage)
                    messages.append(
                        ChatMessage(
                            content: chatNotReadyMessage,
                            isUserMessage: false
                        )
                    )
                    isThinking = false  // Ensure thinking indicator is off
                    return
                }

                // Add a placeholder for the AI response
                let responseIndex = messages.count
                messages.append(
                    ChatMessage(content: "thinking...", isUserMessage: false)
                )
                isThinking = true

                // Reset response-specific stats

                let imageData = imageToSend?.jpegData(compressionQuality: 0.8)

                // Auto-reset conversation when context gets too long to prevent slow prefill.
                // Estimate total tokens from all messages (rough: 1 token ≈ 4 chars).
                let totalChars = messages.reduce(0) { $0 + $1.content.count }
                let estimatedTokens = totalChars / 4
                let contextThreshold = 800  // Reset before hitting maxNumTokens (1024)

                if estimatedTokens > contextThreshold {
                    NSLog(
                        "Context estimated at ~\(estimatedTokens) tokens (threshold: \(contextThreshold)). Resetting conversation to keep inference fast."
                    )
                    do {
                        try await chat.resetConversation()
                        NSLog("Conversation reset successfully.")
                    } catch {
                        NSLog(
                            "Warning: Failed to reset conversation: \(error.localizedDescription)"
                        )
                    }
                }

                // Context Injection: if this is the first message in a loaded session, inject history
                var textToSend = text
                if self.needsContextInjection && messages.count > 1 {
                    let historyMsgs = messages.dropLast().suffix(4)  // Last 4 messages before this new one
                    if !historyMsgs.isEmpty {
                        var historyStr =
                            "Here is the recent conversation history for context:\n"
                        for msg in historyMsgs {
                            let role = msg.isUserMessage ? "User" : "Model"
                            historyStr += "\(role): \(msg.content)\n"
                        }
                        historyStr +=
                            "---\nPlease continue the conversation and respond to this new prompt:\n\(text)"
                        textToSend = historyStr
                        NSLog(
                            "Injected \(historyMsgs.count) messages of history into context."
                        )
                    }
                    self.needsContextInjection = false
                }

                let stream = try await chat.sendMessage(
                    textToSend,
                    imageData: imageData
                )
                var fullResponse = ""

                // Process each chunk of the response
                for try await chunk in stream {
                    try Task.checkCancellation()  // Check for cancellation within the loop
                    fullResponse += chunk
                    // Update the placeholder message with the accumulated response
                    if responseIndex < messages.count {
                        let existingMsg = messages[responseIndex]
                        messages[responseIndex] = ChatMessage(
                            id: existingMsg.id,
                            content: fullResponse,
                            isUserMessage: false,
                            timestamp: existingMsg.timestamp
                        )
                    }
                }

                if responseIndex < messages.count {
                    self.saveMessageToDatabase(messages[responseIndex])
                }

                // Only proceed with stats calculation if not cancelled
                try Task.checkCancellation()

            } catch is CancellationError {
                NSLog("Generation was cancelled.")
            } catch {
                let sendMessageError =
                    "Error during message processing: \(error.localizedDescription)"
                NSLog(sendMessageError)
                messages.append(
                    ChatMessage(content: sendMessageError, isUserMessage: false)
                )
            }
        }
    }

    /// Cancels the ongoing LLM response generation, if any.
    public func stopGeneration() {
        generationTask?.cancel()
        // isThinking will be reset by the defer block in the generationTask
        NSLog("Stop generation requested.")
    }

    // MARK: - Image Handling
    func setSelectedImage(uiImage: UIImage?) {
        self.selectedUIImage = uiImage
    }

    func clearSelectedImage() {
        self.selectedUIImage = nil
    }

    // MARK: - Chat Management
    func clearChat() {
        createNewChatSession()
    }

    // MARK: - Model Switching
    public func switchModel(to newIdentifier: ModelIdentifier) async {
        if newIdentifier == self.selectedModelIdentifier
            && currentOnDeviceModel != nil
            && currentOnDeviceModel?.identifier == newIdentifier
        {
            if currentOnDeviceModel != nil {
                print("Model \(newIdentifier.displayName) is already loaded.")
                return
            }
        }

        print("Switching model to: \(newIdentifier.displayName)")
        self.selectedModelIdentifier = newIdentifier  // This updates @AppStorage

        generationTask?.cancel()  // Cancel any ongoing generation

        messages.removeAll()
        isThinking = false

        clearSelectedImage()
        inputText = ""

        currentChat = nil  // Release old chat session
        currentOnDeviceModel = nil  // Release old model instance

        // loadAndInitializeModel will set isModelLoading, clear messages, and show loading message.
        await loadAndInitializeModel(identifier: newIdentifier)
    }

    // MARK: - Inference Settings Management
    /// Re-initializes the chat session with the current inference settings.
    /// This will clear the current chat history as the LLM context changes.
    public func applyInferenceSettingsAndReinitializeChat() {
        isApplyingSettings = true  // Indicate settings application has started
        generationTask?.cancel()  // Cancel any ongoing generation
        messages.removeAll()
        isThinking = false
        clearSelectedImage()
        inputText = ""

        guard let model = self.currentOnDeviceModel else {
            isApplyingSettings = false
            let noModelErrorMessage = "Cannot apply settings: No model loaded."
            NSLog(noModelErrorMessage)
            messages.append(
                ChatMessage(content: noModelErrorMessage, isUserMessage: false)
            )
            return
        }

        Task { @MainActor in
            do {
                self.currentChat = try await Chat(
                    model: model,
                    topK: 64,
                    topP: 0.95,
                    temperature: 1.0,
                )
                self.isApplyingSettings = false
                messages.append(
                    ChatMessage(
                        content:
                            "Inference settings applied. Chat context reset. Ready for new conversation with \(model.identifier.displayName).",
                        isUserMessage: false
                    )
                )

            } catch {
                self.isApplyingSettings = false
                let applySettingsErrorMessage =
                    "Error applying inference settings: \(error.localizedDescription)"
                NSLog(applySettingsErrorMessage)
                messages.append(
                    ChatMessage(
                        content: applySettingsErrorMessage,
                        isUserMessage: false
                    )
                )
            }
        }
    }
}
