//
//  ExploreViewModel.swift
//  Nooklet
//
//  Created by Tu on 24/6/26.
//

import Foundation

@MainActor
class ExploreViewModel: ObservableObject {
    @Published private(set) var voiceSamples: [VoiceSample] = []
    @Published var playingSampleId: UUID? = nil
    
    private let player = AudioPlayer()

    init() {
        voiceSamples = [
            VoiceSample(
                content:
                    "Chúc bạn một ngày mới tràn đầy năng lượng và niềm vui! Dù có chuyện gì xảy ra, hãy luôn giữ nụ cười trên môi nhé.",
                fileName: "Vietnamese - Daniel.wav",
                author: "Daniel",
                avatar: "avatar7"
            ),
            VoiceSample(
                content:
                    "오늘 하루도 정말 수고 많으셨습니다. 따뜻한 차 한 잔 마시며 푹 쉬세요!",
                fileName: "Korean - Sarah.wav",
                author: "Sarah",
                avatar: "avatar11"
            ),
            VoiceSample(
                content:
                    "失敗を恐れないでください。それは成功への第一歩です。",
                fileName: "Japanese - Lily.wav",
                author: "Lily",
                avatar: "avatar14"
            ),
            VoiceSample(
                content:
                    "Il cibo italiano è famoso in tutto il mondo per la sua semplicità e il suo sapore unico. Buon appetito!",
                fileName: "Italian - Alex.wav",
                author: "Alex",
                avatar: "avatar12"
            ),
            VoiceSample(
                content:
                    "Reading a good book on a rainy afternoon with a cup of coffee is one of life's simplest yet greatest pleasures.",
                fileName: "English - Robert.wav",
                author: "Robert",
                avatar: "avatar2"
            ),
            VoiceSample(
                content:
                    "Selamat pagi! Semoga hari ini membawa banyak kebahagiaan dan kesuksesan untuk kita semua.",
                fileName: "Indonesian - James.wav",
                author: "James",
                avatar: "avatar10"
            ),
            VoiceSample(
                content:
                    "Зима в этом году была очень холодной, но красота заснеженного леса того стоила.",
                fileName: "Russia - Jessica.wav",
                author: "Jessica",
                avatar: "avatar9"
            ),
            VoiceSample(
                content:
                    "सफलता का कोई शॉर्टकट नहीं होता, इसके लिए कड़ी मेहनत और धैर्य की आवश्यकता होती है।",
                fileName: "Hindi - Sam.wav",
                author: "Sam",
                avatar: "avatar8"
            ),
            VoiceSample(
                content:
                    "Hygge er en vigtig del af den danske kultur, især når det sner udenfor, og vi samles om pejsen.",
                fileName: "Danish - Emily.wav",
                author: "Emily",
                avatar: "avatar1"
            ),
            VoiceSample(
                content:
                    "L'amour est comme le vent, on ne peut pas le voir mais on peut le sentir.",
                fileName: "French - Olivia.wav",
                author: "Olivia",
                avatar: "avatar6"
            ),
        ]
    }

    func togglePlay(for sample: VoiceSample) {
        if playingSampleId == sample.id {
            player.stop()
            playingSampleId = nil
        } else {
            // Remove .wav extension if it exists, since playFromBundle appends .wav
            let name = sample.fileName.replacingOccurrences(of: ".wav", with: "")
            
            // Try to find URL in bundle manually to use play(url:) which has completion block
            if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
                player.play(url: url) { [weak self] in
                    DispatchQueue.main.async {
                        if self?.playingSampleId == sample.id {
                            self?.playingSampleId = nil
                        }
                    }
                }
                playingSampleId = sample.id
            } else {
                print("Could not find audio file for \(name).wav")
            }
        }
    }
}
