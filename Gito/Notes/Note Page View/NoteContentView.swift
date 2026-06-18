//
//  NoteContentView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct NoteContentView: View {
    @Binding var content: String
    @Binding var textSize: CGFloat
    @Binding var imageItems: [NoteImageItem]

    @State private var imageCache: [UUID: UIImage] = [:]

    /// Tracked so the large invisible tap area below the text can steal focus back.
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Image attachments ──────────────────────────────
            if !imageItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(imageItems.enumerated()), id: \.element.id) { index, item in
                            if let uiImage = imageCache[item.id] {
                                ImageAttachmentCell(
                                    uiImage: uiImage,
                                    index: index,
                                    imageItems: $imageItems
                                )
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 160, height: 160)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }

            // ── Content text field ─────────────────────────────
            TextField(text: $content, axis: .vertical) {
                Text("Start writing…")
                    .font(.system(size: textSize))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .font(.system(size: textSize))
            .foregroundStyle(.white)
            .focused($isFocused)
            .padding(.top, 12)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .topLeading)

            // ── Large invisible tap target ─────────────────────
            // Fills all remaining space in the ScrollView so tapping
            // anywhere below the typed text will bring up the keyboard.
            Color.clear
                .frame(maxWidth: .infinity, minHeight: 250)
                .contentShape(Rectangle())
                .onTapGesture { isFocused = true }
        }
        .onAppear { rebuildCache() }
        .onChange(of: imageItems) { _, _ in rebuildCache() }
    }

    // MARK: - Image Cache

    private func rebuildCache() {
        var updated: [UUID: UIImage] = [:]
        for item in imageItems {
            if let existing = imageCache[item.id] {
                updated[item.id] = existing
            } else if let decoded = UIImage(data: item.jpegData) {
                updated[item.id] = decoded
            }
        }
        self.imageCache = updated
    }
}
