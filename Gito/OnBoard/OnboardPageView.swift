//
//  OnboardPageView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import UIKit

struct OnboardPageView: View {
    var page: OnboardModel
    var pageIndex: Int
    var totalPages: Int
    var isActive: Bool
    var onContinue: () -> Void

    @State private var symbolScale: CGFloat = 0.6
    @State private var symbolOpacity: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var ringScale: CGFloat = 0.85
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 18
    @State private var badgeOpacity: [Double] = [0, 0, 0]
    @State private var hasAnimated = false

    private var isLastPage: Bool { pageIndex == totalPages - 1 }

    /// Uses the real asset if it exists in the catalog, otherwise falls back to
    /// the SF Symbol — lets you drop in real illustrations page by page without
    /// ever risking a blank/missing-image state.
    private var hasCustomImage: Bool {
        guard let name = page.imageName else { return false }
        return UIImage(named: name) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            if !page.tag.isEmpty {
                Text(page.tag.uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .tracking(2.5)
                    .foregroundStyle(page.accentColor.opacity(0.85))
                    .padding(.top, 8)
                    .opacity(textOpacity)
            }

            Spacer(minLength: 12)

            illustration
                .frame(height: 250)

            Spacer(minLength: 20)

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(white: 0.08))

                Text(page.description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(white: 0.5))
                    .lineSpacing(5)
                    .padding(.horizontal, 30)
            }
            .opacity(textOpacity)
            .offset(y: textOffset)

            Spacer(minLength: 24)

            Button(action: onContinue) {
                HStack(spacing: 10) {
                    Text(isLastPage ? "Let's Begin" : "Continue")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Image(systemName: isLastPage ? "sparkles" : "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .symbolEffect(.bounce, value: isActive)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 16)
                .background(page.accentColor, in: Capsule())
                .shadow(color: page.accentColor.opacity(0.3), radius: 16, y: 8)
            }
            .buttonStyle(PressableButtonStyle())
            .opacity(textOpacity)
            .offset(y: textOffset)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: isActive) { _, active in
            active ? animateIn() : reset()
        }
        .onAppear {
            if isActive { animateIn() }
        }
    }

    // MARK: - Illustration

    @ViewBuilder
    private var illustration: some View {
        ZStack {
            // Ambient halo — slow pulsing ring behind everything
            Circle()
                .fill(page.accentColor.opacity(0.08))
                .frame(width: 230, height: 230)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            Circle()
                .fill(page.accentColor.opacity(0.12))
                .frame(width: 165, height: 165)

            Circle()
                .stroke(page.accentColor.opacity(0.22), lineWidth: 1)
                .frame(width: 165, height: 165)

            if hasCustomImage, let name = page.imageName {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .scaleEffect(symbolScale)
                    .opacity(symbolOpacity)
                    .offset(y: floatOffset)
            } else {
                Image(systemName: page.symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 58, height: 58)
                    .foregroundStyle(page.accentColor)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: isActive)
                    .scaleEffect(symbolScale)
                    .opacity(symbolOpacity)
                    .offset(y: floatOffset)
            }

            // Small decorative SF Symbol badges orbiting the illustration
            ForEach(Array(page.floatingSymbols.enumerated()), id: \.offset) { index, name in
                floatingBadge(systemName: name, index: index)
            }
        }
    }

    private func floatingBadge(systemName: String, index: Int) -> some View {
        let positions: [(CGFloat, CGFloat)] = [(-95, -70), (100, -50), (-85, 80)]
        let pos = positions[index % positions.count]
        return Circle()
            .fill(.white)
            .frame(width: 40, height: 40)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(page.accentColor)
            )
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            .offset(x: pos.0, y: pos.1 + floatOffset * 0.5)
            .opacity(index < badgeOpacity.count ? badgeOpacity[index] : 0)
    }

    // MARK: - Animations

    private func animateIn() {
        guard !hasAnimated else { return }
        hasAnimated = true

        withAnimation(.spring(response: 0.65, dampingFraction: 0.7).delay(0.05)) {
            symbolScale = 1
            symbolOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            textOpacity = 1
            textOffset = 0
        }
        withAnimation(.easeIn(duration: 0.8).delay(0.1)) {
            ringOpacity = 1
        }
        withAnimation(.linear(duration: 3.2).repeatForever(autoreverses: true).delay(0.4)) {
            floatOffset = -8
            ringScale = 1.05
        }
        for index in page.floatingSymbols.indices where index < badgeOpacity.count {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35 + Double(index) * 0.12)) {
                badgeOpacity[index] = 1
            }
        }
    }

    private func reset() {
        hasAnimated = false
        symbolScale = 0.6
        symbolOpacity = 0
        ringOpacity = 0
        ringScale = 0.85
        textOpacity = 0
        textOffset = 18
        floatOffset = 0
        badgeOpacity = [0, 0, 0]
    }
}

// MARK: - Pressable Button Style

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    OnboardPageView(
        page: OnboardModel(
            title: "Your Notes,\nYour Device",
            description: "Everything stays on your device.\nNo cloud. No tracking.\nJust pure, private notes.",
            symbolName: "lock.shield",
            accentColor: Color(hue: 0.60, saturation: 0.55, brightness: 0.60),
            tag: "Privacy First",
            floatingSymbols: ["touchid", "wifi.slash", "icloud.slash"]
        ),
        pageIndex: 0,
        totalPages: 3,
        isActive: true,
        onContinue: {}
    )
}
