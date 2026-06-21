import Foundation
import Combine

final class UserDefaultsService: ObservableObject {

    static let shared = UserDefaultsService()

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        defaults.register(defaults: [
            Key.hasSeenOnboarding.rawValue: false,
            Key.inferenceTopK.rawValue: 40,
            Key.inferenceTopP.rawValue: 0.9,
            Key.inferenceTemperature.rawValue: 1.0,
            Key.inferenceEnableVisionModality.rawValue: false,
            Key.uiIsAutoScrollEnabled.rawValue: true,
        ])

        // Set initial property values
        self.hasSeenOnboarding = false
        self.topK = 40
        self.topP = 0.9
        self.temperature = 1.0
        self.enableVisionModality = false
        self.isAutoScrollEnabled = true

        loadFromDefaults()
    }

    // MARK: - Keys

    /// All UserDefaults keys used in the app, collected in one place.
    enum Key: String {
        case hasSeenOnboarding
        case selectedModelIdentifierRawValue
        case inferenceTopK = "inferenceTopK_v1"
        case inferenceTopP = "inferenceTopP_v1"
        case inferenceTemperature = "inferenceTemperature_v1"
        case inferenceEnableVisionModality = "inferenceEnableVisionModality_v1"
        case uiIsAutoScrollEnabled = "uiIsAutoScrollEnabled_v1"
    }

    // MARK: - Onboarding

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Key.hasSeenOnboarding.rawValue) }
    }

    // MARK: - Inference Settings

    @Published var topK: Int {
        didSet { defaults.set(topK, forKey: Key.inferenceTopK.rawValue) }
    }

    @Published var topP: Double {
        didSet { defaults.set(topP, forKey: Key.inferenceTopP.rawValue) }
    }

    @Published var temperature: Double {
        didSet { defaults.set(temperature, forKey: Key.inferenceTemperature.rawValue) }
    }

    @Published var enableVisionModality: Bool {
        didSet { defaults.set(enableVisionModality, forKey: Key.inferenceEnableVisionModality.rawValue) }
    }

    // MARK: - UI Settings

    @Published var isAutoScrollEnabled: Bool {
        didSet { defaults.set(isAutoScrollEnabled, forKey: Key.uiIsAutoScrollEnabled.rawValue) }
    }

    // MARK: - Generic Accessors

    /// Set any value for a given key.
    func set(_ value: Any?, forKey key: Key) {
        defaults.set(value, forKey: key.rawValue)
    }

    /// Get a Bool value for a given key.
    func bool(forKey key: Key) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    /// Get an Int value for a given key.
    func integer(forKey key: Key) -> Int {
        defaults.integer(forKey: key.rawValue)
    }

    /// Get a Double value for a given key.
    func double(forKey key: Key) -> Double {
        defaults.double(forKey: key.rawValue)
    }

    /// Get a String value for a given key.
    func string(forKey key: Key) -> String? {
        defaults.string(forKey: key.rawValue)
    }

    /// Remove a value for a given key.
    func remove(forKey key: Key) {
        defaults.removeObject(forKey: key.rawValue)
    }

    /// Reset all app-specific UserDefaults keys to their defaults.
    func resetAll() {
        Key.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
        // Re-sync published properties
        loadFromDefaults()
    }

    // MARK: - Private

    /// Load all stored values into the published properties.
    private func loadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding.rawValue)
        
        let loadedTopK = defaults.integer(forKey: Key.inferenceTopK.rawValue)
        if loadedTopK <= 0 {
            topK = 40
            defaults.set(40, forKey: Key.inferenceTopK.rawValue)
        } else {
            topK = loadedTopK
        }
        
        let loadedTopP = defaults.double(forKey: Key.inferenceTopP.rawValue)
        if loadedTopP <= 0.0 {
            topP = 0.9
            defaults.set(0.9, forKey: Key.inferenceTopP.rawValue)
        } else {
            topP = loadedTopP
        }
        
        let loadedTemperature = defaults.double(forKey: Key.inferenceTemperature.rawValue)
        if loadedTemperature <= 0.0 {
            temperature = 1.0
            defaults.set(1.0, forKey: Key.inferenceTemperature.rawValue)
        } else {
            temperature = loadedTemperature
        }
        
        enableVisionModality = defaults.bool(forKey: Key.inferenceEnableVisionModality.rawValue)
        isAutoScrollEnabled = defaults.bool(forKey: Key.uiIsAutoScrollEnabled.rawValue)
    }
}

// MARK: - CaseIterable

extension UserDefaultsService.Key: CaseIterable {}
