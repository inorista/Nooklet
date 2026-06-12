import Foundation

/// Streaming tiers supported by the published Nemotron CoreML model.
/// Chunk windows are seconds-scale, NOT the 320 ms the original draft assumed.
enum StreamingTier: Int, CaseIterable, Identifiable {
    case ms560 = 560
    case ms1120 = 1120
    case ms2240 = 2240   // recommended default
    case ms4480 = 4480

    var id: Int { rawValue }
    var seconds: Double { Double(rawValue) / 1000.0 }
    var displayName: String { "\(String(format: "%.2f", seconds)) s" }

    /// Samples per chunk at 16 kHz.
    var samplesPerChunk: Int { Int(seconds * AudioResampler.targetSampleRate) }

    static let recommended: StreamingTier = .ms2240
}
