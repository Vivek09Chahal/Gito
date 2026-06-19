//
//  VoiceWaveView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/19/26.
//

import SwiftUI

/// Bottom-center "listening" indicator. Bar heights grow with `audioLevel`,
/// so the user can see their own volume reflected back while dictating.
struct VoiceWaveView: View {
    var audioLevel: CGFloat   // 0...1, smoothed mic level
    var isRecording: Bool

    private let barCount = 5

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isRecording)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 6) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(.white)
                        .frame(width: 5, height: barHeight(at: index, time: time))
                }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(Capsule().fill(.white.opacity(0.1)))
        .overlay(Capsule().strokeBorder(.white.opacity(0.15)))
    }

    private func barHeight(at index: Int, time: TimeInterval) -> CGFloat {
        let base: CGFloat = 8
        guard isRecording else { return base }

        let speed = 6.0
        let phase = time * speed + Double(index) * 0.8
        let wiggle = (sin(phase) + 1) / 2          // 0...1, gives the wave motion
        let levelBoost = audioLevel * 36           // grows with how loud the user is speaking

        return base + levelBoost * (0.35 + 0.65 * wiggle)
    }
}
