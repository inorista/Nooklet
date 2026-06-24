import AVFoundation
import Foundation

final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var onFinish: (() -> Void)?

    func play(url: URL, onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
        do {
            let data = try Data(contentsOf: url)
            let player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            print("Audio play error: \(error)")
        }
    }

    func playFromBundle(fileName: String) {
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "wav"
            )
        else {
            print("Erreo: can not found file \(fileName).wav in Bundle.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()

        } catch let error {
            print(
                "Error while reading audio file: \(error.localizedDescription)"
            )
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        onFinish?()
    }
}
