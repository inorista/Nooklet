//
//  LlmInference.swift
//  edgellmtest
//
//  Created by Sidhant Srikumar on 5/23/25.
//

import LiteRTLM
import Foundation
import CoreGraphics // For CGImage

/// Represents the available LLM models, their bundled filenames, and display names.
public enum ModelIdentifier: String, CaseIterable, Identifiable {
    case gemma2B = "gemma-4-E2B-it"

    public var id: String { self.rawValue }
    public var fileName: String { "\(self.rawValue).litertlm" }

    public var displayName: String {
        switch self {
        case .gemma2B: return "Gemma 4 (2B)"
        }
    }

    /// Checks which of the defined models are actually present in the app's main bundle.
    /// - Returns: An array of `ModelIdentifier` cases that have corresponding `.litertlm` files in the bundle.
    public static func availableInBundle() -> [ModelIdentifier] {
        return ModelIdentifier.allCases.filter { modelId in
            Bundle.main.path(forResource: modelId.rawValue, ofType: "litertlm") != nil
        }
    }
}

/// A structure to hold metrics, maintaining compatibility with the existing view model interface.
public struct LlmMetrics {
    public var initializationTimeInSeconds: Double = 0.0
    public var responseGenerationTimeInSeconds: Double = 0.0
}

/// Manages the on-device LLM, including its initialization and model file handling.
struct OnDeviceModel {
    struct InferenceWrapper {
        let metrics: LlmMetrics
    }

    let engine: Engine
    let identifier: ModelIdentifier
    let isVisionAvailable: Bool
    let inference: InferenceWrapper

    init(modelIdentifier: ModelIdentifier) async throws {
        self.identifier = modelIdentifier
        self.isVisionAvailable = false
        var metrics = LlmMetrics()
        
        let fileManager = FileManager.default

        // Use modelIdentifier to get the correct model file
        guard let bundleModelPath = Bundle.main.path(forResource: modelIdentifier.rawValue, ofType: "litertlm") else {
            let errorMessage = "Critical Error: Model file '\(modelIdentifier.fileName)' not found in the app bundle. Please ensure it's added to the project and target."
            NSLog(errorMessage)
            throw NSError(domain: "ModelSetupError", code: 1001, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }

        // Copy model to Caches directory so LiteRT-LM can write its weight cache file (.xnnpack_cache) alongside the model.
        let cachesDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let modelDir = cachesDir.appendingPathComponent("LLMModels")
        try fileManager.createDirectory(at: modelDir, withIntermediateDirectories: true)
        let modelCopyPath = modelDir.appendingPathComponent(modelIdentifier.fileName)

        NSLog("Selected model: \(modelIdentifier.displayName)")
        NSLog("Bundle path: \(bundleModelPath)")
        NSLog("Cache path: \(modelCopyPath.path)")

        // Delete stale cached model + xnnpack_cache when maxNumTokens changes
        // so the engine rebuilds with the correct KV cache dimensions.
        let xnnCachePath = modelDir.appendingPathComponent("\(modelIdentifier.rawValue).litertlm.xnnpack_cache")
        if fileManager.fileExists(atPath: xnnCachePath.path) {
            try? fileManager.removeItem(at: xnnCachePath)
            NSLog("Removed stale xnnpack_cache.")
        }
        if fileManager.fileExists(atPath: modelCopyPath.path) {
            try? fileManager.removeItem(at: modelCopyPath)
            NSLog("Removed stale cached model to force fresh copy.")
        }

        NSLog("Copying model to writable Caches directory...")
        try fileManager.copyItem(atPath: bundleModelPath, toPath: modelCopyPath.path)
        NSLog("Model copied successfully.")

        // Initialize the Engine config.
        // Backend: .gpu (Metal) on physical iOS devices, or .cpu() as fallback.
        // maxNumTokens: 1024 is the safe limit for Gemma 2B on iOS GPU.
        // Higher values (e.g. 2048) cause DYNAMIC_UPDATE_SLICE failures because the
        // KV-cache tensors exceed the device's GPU memory budget.
        let maxTokens = 1024

        #if targetEnvironment(simulator)
        let preferredBackend = Backend.cpu()
        #else
        let preferredBackend = Backend.gpu
        #endif

        var engine: Engine
        let startTime = CFAbsoluteTimeGetCurrent()

        do {
            // Try preferred backend first (GPU on device, CPU on simulator).
            // visionBackend uses CPU because the vision model's STABLEHLO_COMPOSITE
            // ops aren't supported on the device GPU. Using nil would skip the
            // vision executor entirely, breaking image-based prompts.
            let config = try EngineConfig(
                modelPath: modelCopyPath.path,
                backend: preferredBackend,
                visionBackend: .cpu(),
                maxNumTokens: maxTokens,
                cacheDir: modelDir.path
            )
            engine = Engine(engineConfig: config)
            try await engine.initialize()
            NSLog("Engine initialized with preferred backend (vision on CPU).")
        } catch {
            #if !targetEnvironment(simulator)
            // GPU allocation failed — fall back to CPU so the app remains usable.
            NSLog("GPU backend failed (\(error.localizedDescription)). Falling back to CPU.")
            // Remove stale xnnpack cache before CPU retry
            let xnnCacheRetry = modelDir.appendingPathComponent("\(modelIdentifier.rawValue).litertlm.xnnpack_cache")
            try? fileManager.removeItem(at: xnnCacheRetry)

            let cpuConfig = try EngineConfig(
                modelPath: modelCopyPath.path,
                backend: Backend.cpu(),
                visionBackend: .cpu(),
                maxNumTokens: maxTokens,
                cacheDir: modelDir.path
            )
            engine = Engine(engineConfig: cpuConfig)
            try await engine.initialize()
            NSLog("Engine initialized with CPU fallback backend.")
            #else
            throw error
            #endif
        }

        let duration = CFAbsoluteTimeGetCurrent() - startTime
        metrics.initializationTimeInSeconds = duration
        NSLog("Engine initialized in \(String(format: "%.2f", duration)) seconds.")

        self.engine = engine
        self.inference = InferenceWrapper(metrics: metrics)
    }
}

/// Represents a chat session with the loaded on-device LLM.
final class Chat {
    private let model: OnDeviceModel
    private var conversation: Conversation
    private let conversationConfig: ConversationConfig
    private var lastGenerationTime: TimeInterval = 0.0

    init(model: OnDeviceModel, topK: Int = 40, topP: Float = 0.9, temperature: Float = 0.9, enableVisionModality: Bool = true) async throws {
        self.model = model

        let samplerConfig = try SamplerConfig(
            topK: topK,
            topP: topP,
            temperature: temperature
        )

        let config = ConversationConfig(
            samplerConfig: samplerConfig
        )
        self.conversationConfig = config

        self.conversation = try await model.engine.createConversation(with: config)
    }

    func sendMessageSync(_ text: String) async throws -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        let response = try await conversation.sendMessage(LiteRTLM.Message(text))
        lastGenerationTime = CFAbsoluteTimeGetCurrent() - startTime
        return response.toString
    }

    /// Resets the conversation to clear accumulated context, keeping the same engine and sampler config.
    func resetConversation() async throws {
        self.conversation = try await model.engine.createConversation(with: conversationConfig)
        NSLog("Chat conversation has been reset.")
    }

    func sendMessage(_ text: String, imageData: Data? = nil) async throws -> AsyncThrowingStream<String, any Error> {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var contents: [LiteRTLM.Content] = []
        if let data = imageData {
            contents.append(.imageData(data))
        }
        if !text.isEmpty {
            contents.append(.text(text))
        } else if contents.isEmpty {
            // Provide empty text if both are empty just to avoid empty message error
            contents.append(.text(""))
        }
        
        let message = LiteRTLM.Message(contents: contents, role: .user)
        let messageStream = conversation.sendMessageStream(message)
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await chunk in messageStream {
                        continuation.yield(chunk.toString)
                    }
                    self.lastGenerationTime = CFAbsoluteTimeGetCurrent() - startTime
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func getLastResponseGenerationTime() -> TimeInterval? {
        return lastGenerationTime
    }

    public func sizeInTokens(text: String) throws -> Int {
        // Simple token length estimator for UI stats placeholder to avoid compile errors
        return text.count / 4
    }
}
