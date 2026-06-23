import SwiftUI
import Observation

/// Central ViewModel for the recording screen. Wraps `ASRState` and
/// `RecordingService`, exposing observable state and actions to the View layer.
@MainActor
@Observable
final class RecordingViewModel {
    // MARK: - Internal state & service

    private let state = ASRState()
    private var service: RecordingService?
    private var _selectedTier: StreamingTier = .recommended

    init() {}

    /// Called once from the View's `.onAppear`. Lazily creates the service and
    /// checks model availability.
    func onAppear() {
        guard service == nil else { return }
        let svc = RecordingService(state: state)
        service = svc
        svc.refreshAvailability()
    }

    // MARK: - Published state (forwarded from ASRState)

    var status: ASRSessionStatus { state.status }
    var statusMessage: String { state.statusMessage }
    var selectedLanguage: ASRLanguage { state.selectedLanguage }
    var partialTranscript: String { state.partialTranscript }
    var finalTranscript: String { state.finalTranscript }

    /// Normalised microphone level (0…1) for the animated voice orb.
    var audioLevel: Float { state.audioLevel }

    /// Seconds elapsed since recording started.
    var recordingElapsed: TimeInterval { state.recordingElapsed }

    var selectedTier: StreamingTier {
        get { _selectedTier }
        set {
            _selectedTier = newValue
            service?.setTier(newValue)
        }
    }

    // MARK: - Computed UI state

    var canStart: Bool {
        switch status {
        case .ready, .modelsMissing: return true
        default: return false
        }
    }

    var isRecording: Bool {
        status == .recording
    }

    /// Recording or loading the model — both lock language/tier.
    var isSessionActive: Bool {
        status == .recording || status == .loadingModels
    }

    /// Formatted elapsed time string "MM:SS".
    var elapsedFormatted: String {
        let total = Int(recordingElapsed)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Actions

    /// Toggle recording: start if idle/ready, stop if recording.
    func toggleRecording() async {
        if isRecording {
            await service?.stop()
        } else {
            await service?.start()
        }
    }

    func setLanguage(_ language: ASRLanguage) {
        service?.setLanguage(language)
    }

    func clear() {
        service?.clear()
    }
}
