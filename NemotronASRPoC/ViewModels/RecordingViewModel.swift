import SwiftUI
import Observation

/// Central ViewModel for the recording screen. Wraps `ASRState` and
/// `RecordingService`, exposing observable state and actions to the View layer.
///
/// The ViewModel owns the `RecordingService` (née RecordingController) and the
/// `ASRState` it drives. Views bind to the ViewModel's properties instead of
/// reaching into the service or state objects directly.
@MainActor
@Observable
final class RecordingViewModel {
    // MARK: - Internal state & service

    private let state = ASRState()
    private var service: RecordingService?
    private var _selectedTier: StreamingTier = .recommended
    private(set) var isImportingFile = false

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
    var benchmark: BenchmarkSnapshot { state.benchmark }

    var selectedTier: StreamingTier {
        get { _selectedTier }
        set {
            _selectedTier = newValue
            service?.setTier(newValue)
        }
    }

    // MARK: - Computed UI state (moved from ContentView)

    var canStart: Bool {
        switch status {
        case .ready, .modelsMissing: return true  // audio + benchmark work without the model
        default: return false
        }
    }

    /// Recording or loading the model — both lock language/tier/clear/import.
    var isSessionActive: Bool {
        status == .recording || status == .loadingModels
    }

    var isTranscribingFile: Bool {
        if case .transcribingFile = status { return true }
        return false
    }

    var statusColor: Color {
        switch status {
        case .recording: return .red
        case .ready: return .green
        case .transcribingFile: return .blue
        case .modelsMissing: return .orange
        case .permissionDenied, .error: return .red
        default: return .gray
        }
    }

    // MARK: - Actions

    func start() async {
        await service?.start()
    }

    func stop() async {
        await service?.stop()
    }

    func clear() {
        service?.clear()
    }

    func setLanguage(_ language: ASRLanguage) {
        service?.setLanguage(language)
    }

    func showFileImporter() {
        isImportingFile = true
    }

    func dismissFileImporter() {
        isImportingFile = false
    }

    func importFile(url: URL) {
        service?.transcribeImportedFile(url: url)
    }

    func handleImportError(_ error: Error) {
        state.status = .error(error.localizedDescription)
    }

    func cancelTranscription() {
        service?.cancelTranscription()
    }
}
