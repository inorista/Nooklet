import Foundation
import Observation

/// Shared, observable state bridging the audio/ASR pipeline and SwiftUI.
/// All mutations happen on the main actor.
@MainActor
@Observable
final class ASRState {
    var status: ASRSessionStatus = .idle
    var selectedLanguage: ASRLanguage = .englishUS

    /// In-progress hypothesis for the current chunk window (may change).
    var partialTranscript: String = ""
    /// Stable, committed transcript text.
    var finalTranscript: String = ""

    /// Live benchmark snapshot for the on-screen panel.
    var benchmark: BenchmarkSnapshot = .empty

    /// Normalised microphone level (0…1) for the animated voice orb.
    var audioLevel: Float = 0

    /// Seconds elapsed since recording started.
    var recordingElapsed: TimeInterval = 0

    var statusMessage: String {
        switch status {
        case .idle:                       return "Idle"
        case .requestingPermission:       return "Requesting microphone access…"
        case .permissionDenied:           return "Microphone access denied. Enable it in Settings."
        case .modelsMissing(let reason):  return "Models not found — \(reason)"
        case .loadingModels:              return "Loading model…"
        case .ready:                      return "Ready"
        case .recording:                  return "Recording…"
        case .finishing:                  return "Finalizing transcript…"
        case .transcribingFile(let p):    return p.isEmpty ? "Transcribing file…" : "Transcribing file… \(p)"
        case .error(let message):         return "Error: \(message)"
        }
    }

    func clearTranscripts() {
        partialTranscript = ""
        finalTranscript = ""
    }

    /// Commit the current partial into the final transcript (called when a chunk
    /// is finalized or recording stops).
    func commitPartial() {
        guard !partialTranscript.isEmpty else { return }
        if finalTranscript.isEmpty {
            finalTranscript = partialTranscript
        } else {
            let joiner = selectedLanguage.isCJK ? "" : " "
            finalTranscript += joiner + partialTranscript
        }
        partialTranscript = ""
    }
}
