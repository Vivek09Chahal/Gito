//
//  HomeBottomNavBar.swift
//  Gito
//
//  Refactored from homeViewNavStack.swift.
//  Floating liquid-glass pill navigation bar — Google Keep style.
//

import SwiftUI

struct HomeBottomNavBar: View {
    var onAction: (HomeBottomNavAction) -> Void

    var body: some View {
        HStack(spacing: 0) {
            navButton(icon: "checkmark.square",  action: .newTextNote)
            navButton(icon: "textformat",        action: .newDrawingNote)
            navButton(icon: "mic",               action: .newVoiceNote)
            navButton(icon: "photo",             action: .newImageNote)

            Spacer(minLength: 0)

            Button { onAction(.newTextNote) } label: { embeddedFAB }
                .buttonStyle(.plain)
                .padding(.trailing, 8)
        }
        .padding(.leading, 4)
        .frame(height: 62)
        .background { glassPill }
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    @ViewBuilder
    private func navButton(icon: String, action: HomeBottomNavAction) -> some View {
        Button { onAction(action) } label: {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Color.primary.opacity(0.6))
                .frame(width: 56, height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var embeddedFAB: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(white: 0.40),
                            Color(white: 0.22)
                        ],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: 24
                    )
                )
                .frame(width: 46, height: 46)
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                )
                .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)

            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var glassPill: some View {
        ZStack {
            Capsule()
                .fill(.ultraThinMaterial)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.16, opacity: 0.90),
                            Color(white: 0.10, opacity: 0.97)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color.white.opacity(0.00)
                        ],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.55)
                    )
                )

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.00),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0.6),
                        endPoint: .bottom
                    )
                )

            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.28),
                            Color.white.opacity(0.04),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            HomeBottomNavBar { _ in }
        }
    }
}
