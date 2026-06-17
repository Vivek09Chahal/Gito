//
//  nebulaView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI

// Struct to manage individual star positions and types
struct CosmicStar: Identifiable {
    let id = UUID()
    let position: CGPoint   // Normalized (0...1)
    let size: CGFloat
    let twinkleSpeed: Double
    let phaseOffset: Double
    let opacityMax: Double
}

struct GrainyCosmicView: View {
    @State private var stars: [CosmicStar] = []
    private let startDate = Date()

    // Adjust density here
    private let totalStarsCount = 800

    init() {
        var generatedStars: [CosmicStar] = []

        for _ in 0..<totalStarsCount {
            let isTrailStar = Double.random(in: 0...1) < 0.55

            var targetX: CGFloat = 0
            var targetY: CGFloat = 0

            if isTrailStar {
                let progress = CGFloat.random(in: 0.0...1.0)
                let startPoint = CGPoint(x: -0.1, y: 1.1)
                let endPoint = CGPoint(x: 0.7, y: 0.3)

                let lineX = startPoint.x + (endPoint.x - startPoint.x) * progress
                let lineY = startPoint.y + (endPoint.y - startPoint.y) * progress

                let spread: CGFloat = 0.08
                targetX = lineX + CGFloat.random(in: -spread...spread)
                targetY = lineY + CGFloat.random(in: -spread...spread)
            } else {
                targetX = CGFloat.random(in: 0...1)
                targetY = CGFloat.random(in: 0...1)
            }

            let isBrightStar = Double.random(in: 0...1) < 0.15
            let size = isBrightStar ? CGFloat.random(in: 2.0...4.5) : CGFloat.random(in: 0.4...1.2)
            let maxOpacity = isBrightStar ? Double.random(in: 0.8...1.0) : Double.random(in: 0.2...0.6)

            generatedStars.append(
                CosmicStar(
                    position: CGPoint(x: targetX, y: targetY),
                    size: size,
                    // --- CHANGED HERE: Lower values make the sine wave cycle much slower ---
                    twinkleSpeed: Double.random(in: 0.4...1.8),
                    phaseOffset: Double.random(in: 0...Double.pi * 2),
                    opacityMax: maxOpacity
                )
            )
        }
        _stars = State(initialValue: generatedStars)
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince(startDate)

            ZStack {
                // LAYER 1: Deep Space Base
                Color(red: 0.03, green: 0.01, blue: 0.0)

                // LAYER 2: Wide, Spread-Out Amber Nebula Core
                RadialGradient(
                    colors: [
                        Color(red: 0.65, green: 0.32, blue: 0.08).opacity(0.55),
                        Color(red: 0.25, green: 0.10, blue: 0.02).opacity(0.35),
                        Color.black.opacity(0.9)
                    ],
                    center: .init(x: 0.2, y: 0.7), // Aligned with the star cluster origin
                    startRadius: 20,
                    endRadius: 550
                )
                .blendMode(.screen)

                // LAYER 3: Film Grain Texture Over the Gradient
                Canvas { context, size in
                    // Generates a high-frequency grain matrix natively
                    for _ in 0..<1500 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let grainSize = CGFloat.random(in: 0.8...1.8)

                        let rect = CGRect(x: x, y: y, width: grainSize, height: grainSize)
                        context.opacity = Double.random(in: 0.03...0.12)
                        context.fill(Path(rect), with: .color(Color(red: 0.9, green: 0.6, blue: 0.3)))
                    }
                }
                .blendMode(.overlay)

                // LAYER 4: Dense Custom Clustered Star Field
                Canvas { context, size in
                    for star in stars {
                        let starX = star.position.x * size.width
                        let starY = star.position.y * size.height

                        // Handle layout bounds checking smoothly
                        guard starX >= 0, starX <= size.width, starY >= 0, starY <= size.height else { continue }

                        // Calculate independent twinkling animation loop
                        let sineWave = (sin(time * star.twinkleSpeed + star.phaseOffset) + 1.0) / 2.0
                        let currentOpacity = (star.opacityMax * 0.3) + (sineWave * (star.opacityMax * 0.7))

                        var path = Path()
                        let r = star.size

                        if r > 2.0 {
                            // Large foreground stars: Rendered as 4-pointed diamond flares
                            path.move(to: CGPoint(x: starX, y: starY - r))
                            path.addQuadCurve(to: CGPoint(x: starX + r, y: starY), control: CGPoint(x: starX, y: starY))
                            path.addQuadCurve(to: CGPoint(x: starX, y: starY + r), control: CGPoint(x: starX, y: starY))
                            path.addQuadCurve(to: CGPoint(x: starX - r, y: starY), control: CGPoint(x: starX, y: starY))
                            path.addQuadCurve(to: CGPoint(x: starX, y: starY - r), control: CGPoint(x: starX, y: starY))
                        } else {
                            // Tiny background stellar noise specs: Rendered as performance-friendly circles
                            path.addEllipse(in: CGRect(x: starX - r/2, y: starY - r/2, width: r, height: r))
                        }

                        context.opacity = currentOpacity
                        context.fill(path, with: .color(Color(red: 1.0, green: 0.92, blue: 0.85)))
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    GrainyCosmicView()
}
