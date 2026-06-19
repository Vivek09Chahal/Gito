//
//  SpeechView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/19/26.
//

import Foundation
import AVFoundation
import Speech
import Observation

/// Handles microphone capture + live speech-to-text transcription.
/// Kept fully separate from the editor view-model so the recording/recognition
/// plumbing can be tested or swapped out without touching note-editing logic.
@Observable
final class SpeechToTextManager: NSObject {

    // MARK: - Published State (drives the UI)

    /// The full text that should be shown in the editor (base + spoken segment).
    var transcribedText: String = ""

    var isRecording: Bool = false

    /// Normalized 0...1 microphone level, used to size the wave animation.
    var audioLevel: CGFloat = 0

    var authorizationError: String? = nil

    // MARK: - Speech / Audio Engine
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    /// Text already in the editor before this recording session began, so partial
    /// results get appended after it instead of replacing whatever was typed.
    private(set) var baseText: String = ""

    /// The glue string inserted between `baseText` and the new spoken segment.
    /// Computed once when recording starts so it stays stable across partial results.
    private var joinPrefix: String = ""

    // MARK: - Permissions
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            guard speechStatus == .authorized else {
                DispatchQueue.main.async {
                    self?.authorizationError = "Speech recognition isn't authorized. Enable it in Settings."
                    completion(false)
                }
                return
            }
            AVAudioApplication.requestRecordPermission { micGranted in
                DispatchQueue.main.async {
                    if !micGranted {
                        self?.authorizationError = "Microphone access isn't authorized. Enable it in Settings."
                    }
                    completion(micGranted)
                }
            }
        }
    }

    // MARK: - Start / Stop

    /// Call this with the *current* editor text before the user starts dictating.
    func startRecording(existingText: String) {
        guard !isRecording else { return }
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            authorizationError = "Speech recognizer is unavailable right now."
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            authorizationError = "Couldn't configure the audio session."
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        // Ask Apple servers for punctuation when available (iOS 16+)
        if #available(iOS 16, *) {
            request.addsPunctuation = true
        }
        recognitionRequest = request

        baseText = existingText
        // Pre-compute the join string once so every partial result uses the same separator.
        joinPrefix = joinSeparator(for: existingText)
        transcribedText = existingText

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // installTap will hard-crash if handed a 0 Hz / 0-channel format, which can
        // happen for a moment right after permission is granted. Fail soft instead.
        guard recordingFormat.sampleRate > 0, recordingFormat.channelCount > 0 else {
            authorizationError = "Microphone isn't ready yet — try again in a moment."
            try? session.setActive(false, options: .notifyOthersOnDeactivation)
            return
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateAudioLevel(from: buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            authorizationError = "Couldn't start the audio engine."
            return
        }

        isRecording = true

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                let spokenSegment = result.bestTranscription.formattedString
                let combined = self.combineText(base: self.baseText,
                                                prefix: self.joinPrefix,
                                                spoken: spokenSegment)
                DispatchQueue.main.async { self.transcribedText = combined }
            }
            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async { self.stopRecording() }
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        audioLevel = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Smart Text Joining

    /// Determines the separator to inject between existing text and the new speech segment.
    ///
    /// Rules:
    ///  - If `base` is empty → no separator needed (spoken text starts fresh).
    ///  - If `base` ends with whitespace/newline → single space (already separated).
    ///  - If `base` ends with `.`, `!`, `?`, `…` → ` ` (sentence already terminated).
    ///  - If `base` ends with `,`, `;`, `:` → ` ` (clause continues, no extra period).
    ///  - Otherwise (mid-word / mid-sentence) → `. ` so we close the typed sentence first.
    private func joinSeparator(for base: String) -> String {
        let trimmed = base.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let last = trimmed.last!

        // Already ends with a sentence terminator or clause separator — just add a space.
        let sentenceTerminators: Set<Character> = [".", "!", "?", "…"]
        let clauseSeparators:    Set<Character> = [",", ";", ":", "-", "–", "—"]

        if sentenceTerminators.contains(last) || clauseSeparators.contains(last) {
            return " "
        }

        // Base text ends mid-sentence → append a period + space so speech is a new sentence.
        return ". "
    }

    /// Capitalizes the first letter of a spoken segment when the join prefix ends the sentence.
    private func combineText(base: String, prefix: String, spoken: String) -> String {
        guard !spoken.isEmpty else { return base }
        if base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return spoken
        }

        // If the prefix contains ". " (we added a period), capitalize the first spoken word.
        let shouldCapitalize = prefix.contains(".")
        let adjustedSpoken = shouldCapitalize ? capitalizeFirstLetter(of: spoken) : spoken

        return base + prefix + adjustedSpoken
    }

    private func capitalizeFirstLetter(of text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }

    // MARK: - Audio Level
    private func updateAudioLevel(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return }

        var sum: Float = 0
        for i in 0..<frameLength { sum += channelData[i] * channelData[i] }
        let rms = sqrt(sum / Float(frameLength))
        let normalized = min(max(CGFloat(rms) * 12, 0), 1)

        DispatchQueue.main.async {
            // Light smoothing so the wave doesn't jitter on every buffer.
            self.audioLevel = self.audioLevel * 0.6 + normalized * 0.4
        }
    }
}
