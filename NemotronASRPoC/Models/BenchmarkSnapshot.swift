import Foundation

/// Immutable snapshot of the metrics shown in the on-screen benchmark panel.
struct BenchmarkSnapshot: Equatable {
    var modelLoadMS: Double
    var firstPartialLatencyMS: Double
    var chunkP50MS: Double
    var chunkP90MS: Double
    var chunkP99MS: Double
    var averageChunkMS: Double
    var realTimeFactor: Double
    var peakMemoryMB: Double
    var currentMemoryMB: Double
    var recordingSeconds: Double
    var thermalState: String

    static let empty = BenchmarkSnapshot(
        modelLoadMS: 0, firstPartialLatencyMS: 0,
        chunkP50MS: 0, chunkP90MS: 0, chunkP99MS: 0, averageChunkMS: 0,
        realTimeFactor: 0, peakMemoryMB: 0, currentMemoryMB: 0,
        recordingSeconds: 0, thermalState: "—"
    )
}
