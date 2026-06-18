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
            navButton(icon: "pencil.tip",        action: .newDrawingNote)
            navButton(icon: "mic",               action: .newVoiceNote)
            navButton(icon: "photo",             action: .newImageNote)

            Spacer(minLength: 0)

            Button {
                onAction(.newTextNote)
            } label: {
                embeddedFAB
            }
            .buttonStyle(.plain)
            .padding(.trailing, 8)
        }
        .padding(.leading, 4)
        .frame(height: 62)
        .background { morphicPill }
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
                            Color(white: 0.2),
                            Color(white: 0.2)
                        ],
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: 24
                    )
                )
                .frame(width: 46, height: 46)
                .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)

            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var morphicPill: some View {
        ZStack {
            Capsule()

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.02, opacity: 0.9),
                            Color(white: 0.04, opacity: 0.99)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
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
