import Foundation
import Speech
import AVFoundation

public class SpeechRecognizer: ObservableObject {
    @Published public var transcript: String = ""
    @Published public var isRecording: Bool = false
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    public init() {
        speechRecognizer = SFSpeechRecognizer()
    }
    
    @MainActor
    public func startTranscribing(onUpdate: @escaping (String) -> Void) {
        guard speechRecognizer?.isAvailable == true else {
            return
        }
        
        do {
            try configureAudioSession()
            try startRecognitionTask(onUpdate: onUpdate)
            isRecording = true
        } catch {
            stopTranscribing()
        }
    }
    
    @MainActor
    public func stopTranscribing() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        audioEngine = nil
        inputNode = nil
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    @MainActor
    private func startRecognitionTask(onUpdate: @escaping (String) -> Void) throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        inputNode = audioEngine.inputNode
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            if let result = result {
                let text = result.bestTranscription.formattedString
                onUpdate(text)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                Task { @MainActor in
                    self.stopTranscribing()
                }
            }
        }
        
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    public static func requestPermission(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
}
