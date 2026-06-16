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
    case gemma2B = "gemma-3n-E2B-it-int4"
    case gemma4B = "gemma-3n-E4B-it-int4"

    public var id: String { self.rawValue }
    public var fileName: String { "\(self.rawValue).litertlm" }

    public var displayName: String {
        switch self {
        case .gemma2B: return "Gemma 3N (2B)"
        case .gemma4B: return "Gemma 3N (4B)"
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

        if !fileManager.fileExists(atPath: modelCopyPath.path) {
            NSLog("Copying model to writable Caches directory...")
            try fileManager.copyItem(atPath: bundleModelPath, toPath: modelCopyPath.path)
            NSLog("Model copied successfully.")
        } else {
            NSLog("Model already exists in Caches directory.")
        }

        // Initialize the Engine config.
        // Backend: .gpu (Metal) on physical iOS devices, or .cpu() as fallback.
        #if targetEnvironment(simulator)
        let backend = Backend.cpu()
        #else
        let backend = Backend.gpu
        #endif

        let config = try EngineConfig(
            modelPath: modelCopyPath.path,
            backend: backend,
            maxNumTokens: 256, // Minimal KV cache to reduce memory pressure
            cacheDir: modelDir.path
        )

        let engine = Engine(engineConfig: config)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        try await engine.initialize()
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

        self.conversation = try await model.engine.createConversation(with: config)
    }

    func sendMessageSync(_ text: String) async throws -> String {
        let startTime = CFAbsoluteTimeGetCurrent()
        let response = try await conversation.sendMessage(LiteRTLM.Message(text))
        lastGenerationTime = CFAbsoluteTimeGetCurrent() - startTime
        return response.toString
    }

    public func addImageToQuery(image: CGImage) throws {
        // Multi-modality disabled to save memory / CPU load on iOS for now
        NSLog("Warning: Vision modality is not supported yet in LiteRTLM wrapper.")
    }

    func sendMessage(_ text: String) async throws -> AsyncThrowingStream<String, any Error> {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        let messageStream = conversation.sendMessageStream(LiteRTLM.Message(text))
        
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
