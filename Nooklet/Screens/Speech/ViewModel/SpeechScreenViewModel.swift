import AVFoundation
import Foundation

@MainActor
final class SpeechScreenViewModel: ObservableObject {
    @Published var text: String =
        "Hi there, I'm Nooklet! Drop your text here, and let me bring it to life with voice."
    @Published var nfe: Double = 9
    @Published var voice: SupertonicService.Voice = .f1
    @Published var language: SupertonicService.Language = .en
    @Published var isGenerating: Bool = false
    @Published var isPlaying: Bool = false
    @Published var errorMessage: String?
    @Published var audioURL: URL?
    @Published var elapsedSeconds: Double?
    @Published var audioSeconds: Double?

    private var service: SupertonicService?
    private var player = AudioPlayer()

    var rtfText: String? {
        guard let e = elapsedSeconds, let a = audioSeconds, a > 0 else {
            return nil
        }
        return String(format: "RTF %.2fx · %.2fs / %.2fs", e / a, e, a)
    }

    func startup() {
        do {
            service = try SupertonicService()
        } catch {
            errorMessage = "Failed to init TTS: \(error.localizedDescription)"
        }
    }

    func generate() {
        guard let service = service else { return }
        isGenerating = true
        errorMessage = nil
        audioURL = nil
        elapsedSeconds = nil
        audioSeconds = nil
        Task {
            let tic = Date()
            do {
                let url = try await service.synthesize(
                    text: text,
                    nfe: Int(nfe),
                    voice: voice,
                    language: language
                )
                let elapsed = Date().timeIntervalSince(tic)
                let audio = audioDuration(at: url)
                await MainActor.run {
                    self.audioURL = url
                    self.elapsedSeconds = elapsed
                    self.audioSeconds = audio
                    self.isGenerating = false
                    self.play(url: url)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isGenerating = false
                }
            }
        }
    }

    func togglePlay() {
        if isPlaying {
            player.stop()
            isPlaying = false
        } else if let url = audioURL {
            play(url: url)
        }
    }

    private func play(url: URL) {
        player.play(url: url) { [weak self] in
            DispatchQueue.main.async { self?.isPlaying = false }
        }
        isPlaying = true
    }

    private func audioDuration(at url: URL) -> Double? {
        guard let file = try? AVAudioFile(forReading: url) else { return nil }
        return Double(file.length) / file.fileFormat.sampleRate
    }
}
