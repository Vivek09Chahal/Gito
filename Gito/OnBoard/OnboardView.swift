//
//  OnboardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/12/26.
//

import SwiftUI

struct OnboardView: View {
    // MARK: - Pages

    let pages: [OnboardModel] = [
        // 1 – Privacy / Local-first
        OnboardModel(
            title: "Your Notes,\nYour Device",
            description: "Everything stays on your device.\nNo cloud. No tracking.\nJust pure, private notes.",
            symbolName: "lock.shield",
            imageName: "onboard_privacy",   // drop this into Assets.xcassets to replace the symbol
            accentColor: Color(hue: 0.60, saturation: 0.55, brightness: 0.60),   // slate blue
            tag: "Privacy First",
            floatingSymbols: ["touchid", "wifi.slash", "icloud.slash"]
        ),
        // 2 – Canvas / Drawing
        OnboardModel(
            title: "Sketch Your\nThoughts",
            description: "Draw freely on any note.\nFinger or Apple Pencil — every\nidea has a canvas.",
            symbolName: "pencil.and.scribble",
            imageName: "onboard_canvas",
            accentColor: Color(hue: 0.75, saturation: 0.45, brightness: 0.58),   // soft violet
            tag: "Canvas",
            floatingSymbols: ["pencil.tip", "scribble.variable", "paintbrush.pointed.fill"]
        ),
        // 3 – Photos & Voice
        OnboardModel(
            title: "Capture Every\nMoment",
            description: "Add photos, record your voice,\nand write — all inside\none beautiful note.",
            symbolName: "waveform.and.mic",
            imageName: "onboard_capture",
            accentColor: Color(hue: 0.07, saturation: 0.60, brightness: 0.72),   // warm terracotta
            tag: "Rich Notes",
            floatingSymbols: ["photo.on.rectangle.angled", "mic.fill", "waveform"]
        )
    ]

    // MARK: - State

    @State private var scrollPosition: Int?
    @State private var currentPage: Int = 0
    var onFinished: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack {
            AmbientBackground(accentColor: pages[safe: currentPage]?.accentColor ?? .blue)

            VStack(spacing: 0) {
                topBar

                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            OnboardPageView(
                                page: page,
                                pageIndex: index,
                                totalPages: pages.count,
                                isActive: index == currentPage,
                                onContinue: { advance(from: index) }
                            )
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition(.animated(.smooth)) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.4)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $scrollPosition)
                .scrollIndicators(.hidden)
                .onChange(of: scrollPosition) { _, newValue in
                    guard let newValue else { return }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = newValue
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: currentPage)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Spacer()
            if currentPage < pages.count - 1 {
                Button("Skip", action: onFinished)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .frame(height: 36)
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }

    // MARK: - Navigation

    private func advance(from index: Int) {
        if index < pages.count - 1 {
            jump(to: index + 1)
        } else {
            onFinished()
        }
    }

    private func jump(to index: Int) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            scrollPosition = index
            currentPage = index
        }
    }
}

// MARK: - Ambient animated background

private struct AmbientBackground: View {
    let accentColor: Color
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.white

            Circle()
                .fill(accentColor.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: animate ? -90 : -130, y: animate ? -210 : -260)

            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: animate ? 130 : 160, y: animate ? 260 : 300)
        }
        .animation(.easeInOut(duration: 0.6), value: accentColor)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Page indicator

private struct PageIndicator: View {
    let count: Int
    let currentPage: Int
    let accentColor: Color
    var onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? accentColor : Color.black.opacity(0.12))
                    .frame(width: index == currentPage ? 22 : 7, height: 7)
                    .onTapGesture { onTap(index) }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentPage)
    }
}

// MARK: - Safe array access

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    OnboardView(onFinished: {
        print("Onboarding finished!")
    })
}
