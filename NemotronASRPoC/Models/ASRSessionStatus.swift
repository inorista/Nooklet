import Foundation

/// High-level lifecycle of the recording / inference session, surfaced to the UI.
enum ASRSessionStatus: Equatable {
    case idle
    case requestingPermission
    case permissionDenied
    case modelsMissing(reason: String)
    case loadingModels
    case ready
    case recording
    case finishing
    /// Offline transcription of an imported file is running; `progress` is a
    /// short human label such as "segment 2/14" (empty while audio loads).
    case transcribingFile(progress: String)
    case error(String)

    var isBusy: Bool {
        switch self {
        case .requestingPermission, .loadingModels, .finishing, .transcribingFile: return true
        default: return false
        }
    }

    var canStartRecording: Bool {
        switch self {
        case .ready: return true
        default: return false
        }
    }
}
