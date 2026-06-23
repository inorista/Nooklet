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


enum NookletModelInitStatus: Hashable  {
    case loading(modelName: String)
    case failed(modelName: String)
    case loaded(userName: String)

    var displayStatus: String{
        switch self{
        case .loading(let modelName):
            "The \(modelName) model is initializing..."
        case .failed(let modelName):
            "Failed to load the \(modelName) model. Please try again."
        case .loaded(let userName):
            "Feel free to ask, \(userName)!"
        }
    }
}


@MainActor
class ChatViewModel: ObservableObject {
    @Published var showDeleteSheet: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isModelLoading: Bool = true
    @Published var isThinking: Bool = false
    @Published var modelInitStatus: NookletModelInitStatus = .loading(modelName: "")
    @Published var selectedUIImage: UIImage?

    /// Stores a critical error message if model initialization fails
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
    @Published public var currentSession: ChatSessionEntity?
    private var needsContextInjection: Bool = false

    @Published var showImagePicker: Bool = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .camera
    @Published var isRecordingSpeech: Bool = false
    
    public let speechRecognizer = SpeechRecognizer()
    
    init() {
        speechRecognizer.$isRecording
            .receive(on: DispatchQueue.main)
            .assign(to: &$isRecordingSpeech)

        Task {
            self.availableModels = ModelIdentifier.availableInBundle()

            if availableModels.isEmpty {
                let noModelsErrorMessage =
                    "Critical Error: No LLM models found in the app bundle. Please ensure model files (e.g., *.task) are correctly added to the project."
                NSLog(noModelsErrorMessage)
                isModelLoading = false
                modelInitStatus = .failed(modelName: "Gemma 4")
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
        modelInitStatus = .loading(modelName: identifier.displayName)
        isModelLoading = true
        messages.removeAll()
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
            let user = try? RealmService.shared.getUser()
            let userName = user?.firstName ?? "User"
            modelInitStatus = .loaded(userName: userName)
        } catch {
            let loadErrorMessage =
                "Error initializing \(identifier.displayName): \(error.localizedDescription)"
            NSLog(loadErrorMessage)
            modelInitStatus = .failed(modelName: identifier.displayName)
        }

        isModelLoading = false
        isThinking = false
        clearSelectedImage()
        inputText = ""
    }

    // MARK: - Realm Integration
    public func loadInitialData(sessionId: UUID?) async {
        if let id = sessionId {
            do {
                if let session = try RealmService.shared.getChatSession(
                    by: id
                ) {
                    loadSession(session)
                    return
                }
            } catch {
                print("Error finding session by ID: \(error)")
            }
        } else {
            self.currentSession = nil
            self.messages = []
            Task {
                try? await self.currentChat?.resetConversation()
            }
            self.needsContextInjection = false
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
        if currentSession == nil {
            do {
                let newSession = try RealmService.shared.createNewChatSession()
                self.currentSession = newSession
            } catch {
                print("Error creating new session: \(error)")
                return
            }
        }

        guard let session = currentSession else { return }

        do {
            let entity = ChatMessageEntity.fromModel(message)
            try RealmService.shared.saveMessage(entity, to: session)
        } catch {
            print("Error saving message: \(error)")
        }
    }

    private func sanitizeLLMOutput(_ text: String) -> String {
        var cleaned = text.replacingOccurrences(of: "[multimodal]", with: "")
        
        // Define patterns for special tokens to be stripped.
        // This includes:
        // - <pad>, <bos>, <eos>
        // - <unusedX> (where X is any digits)
        // - <maskX>
        // - Any tags containing '|' (e.g. <|tool_call|>, <tool_call|>, <|tool_call>, etc.)
        // - Any tags starting with <tool or <mask
        let pattern = "(?i)<(?:pad|bos|eos|unused\\d+|mask\\d*|[^>]*\\|[^>]*|\\/?tool[^>]*|\\/?mask[^>]*)>"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned)
            cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func estimateTokens(for text: String) -> Int {
        let isNonAscii = text.contains { !$0.isASCII }
        let divisor = isNonAscii ? 1.8 : 3.5
        return Int(Double(text.count) / divisor)
    }

    // Send a message from the user to the LLM
    func sendMessage(_ text: String) {
        let imageToSend = selectedUIImage

        guard
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || imageToSend != nil
        else { return }

        // Trim input text if it is exceptionally long to avoid native layer crash (max 1600 characters)
        var sanitizedText = text
        let estimatedPromptTokens = estimateTokens(for: text)
        if estimatedPromptTokens > 900 {
            let safeCharLimit = 1600
            sanitizedText = String(text.prefix(safeCharLimit)) + "\n[Message truncated to prevent memory overload]"
            NSLog("User message exceeded token limit (~ \(estimatedPromptTokens) tokens). Trimmed to 1600 characters to prevent crash.")
        }

        let userMessage = ChatMessage(
            content: sanitizedText,
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
                // Estimate total tokens from all messages using our multilingual estimator.
                let totalText = messages.map { $0.content }.joined(separator: "\n")
                let estimatedTokens = self.estimateTokens(for: totalText)
                let contextThreshold = 750  // Reset before hitting maxNumTokens (1024)

                if estimatedTokens > contextThreshold {
                    NSLog(
                        "Context estimated at ~\(estimatedTokens) tokens (threshold: \(contextThreshold)). Resetting conversation to keep inference fast."
                    )
                    do {
                        try await chat.resetConversation()
                        self.needsContextInjection = true
                        NSLog(
                            "Conversation reset successfully and context injection queued."
                        )
                    } catch {
                        NSLog(
                            "Warning: Failed to reset conversation: \(error.localizedDescription)"
                        )
                    }
                }

                // Context Injection: if this is the first message in a loaded session, inject history
                var textToSend = sanitizedText
                if self.needsContextInjection && messages.count > 1 {
                    let historyMsgs = Array(messages.dropLast().suffix(4))  // Last 4 messages
                    if !historyMsgs.isEmpty {
                        var historyParts: [String] = []
                        var currentHistoryTokens = 0
                        // Reserve 450 tokens for the new message + safety buffer
                        let maxHistoryTokens = 1024 - 450
                        
                        for msg in historyMsgs.reversed() {
                            let role = msg.isUserMessage ? "User" : "Model"
                            let msgText = "\(role): \(msg.content)\n"
                            let msgTokens = self.estimateTokens(for: msgText)
                            
                            if currentHistoryTokens + msgTokens <= maxHistoryTokens {
                                historyParts.insert(msgText, at: 0) // Prepend to keep chronological order
                                currentHistoryTokens += msgTokens
                            } else {
                                break // Stop adding older history to stay within token budget
                            }
                        }
                        
                        if !historyParts.isEmpty {
                            var historyStr = "Here is the recent conversation history for context:\n"
                            historyStr += historyParts.joined()
                            historyStr += "---\nPlease continue the conversation and respond to this new prompt:\n\(sanitizedText)"
                            
                            // Verify the overall constructed prompt is safe (under 900 tokens)
                            let totalPromptTokens = self.estimateTokens(for: historyStr)
                            if totalPromptTokens < 900 {
                                textToSend = historyStr
                                NSLog("Injected \(historyParts.count) messages of history into context (~ \(currentHistoryTokens) tokens).")
                            } else {
                                NSLog("Constructed history prompt is too large (\(totalPromptTokens) tokens). Skipping history injection to prevent crash.")
                            }
                        }
                    }
                    self.needsContextInjection = false
                }

                // Only pass image data if the model supports vision to prevent native layer crash
                let supportedImageData = self.currentOnDeviceModel?.isVisionAvailable == true ? imageData : nil
                
                if imageData != nil && supportedImageData == nil {
                    NSLog("Warning: Image was attached but the current model does not support vision. The image will be ignored by the model.")
                }

                let stream = try await chat.sendMessage(
                    textToSend,
                    imageData: supportedImageData
                )
                var fullResponse = ""

                // Process each chunk of the response
                for try await chunk in stream {
                    try Task.checkCancellation()  // Check for cancellation within the loop
                    fullResponse += chunk
                    // Update the placeholder message with the accumulated response
                    if responseIndex < messages.count {
                        let existingMsg = messages[responseIndex]
                        let sanitized = sanitizeLLMOutput(fullResponse)
                        messages[responseIndex] = ChatMessage(
                            id: existingMsg.id,
                            content: sanitized.isEmpty ? "..." : sanitized,
                            isUserMessage: false,
                            timestamp: existingMsg.timestamp
                        )
                    }
                }

                if responseIndex < messages.count {
                    let finalSanitized = sanitizeLLMOutput(fullResponse)
                    messages[responseIndex] = ChatMessage(
                        id: messages[responseIndex].id,
                        content: finalSanitized.isEmpty ? "..." : finalSanitized,
                        isUserMessage: false,
                        timestamp: messages[responseIndex].timestamp
                    )
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

    public func deleteCurrentSession() {
        guard let session = currentSession else { return }
        do {
            try RealmService.shared.deleteChatSession(by: session.id)
            self.currentSession = nil
            self.messages = []
        } catch {
            print("Error deleting current session: \(error)")
        }
    }

    public func toggleSpeechRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            SpeechRecognizer.requestPermission { [weak self] authorized in
                guard let self = self, authorized else { return }
                self.speechRecognizer.startTranscribing { text in
                    self.inputText = text
                }
            }
        }
    }
}
