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

    var body: some View {
        VStack {
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

            TextField(text: $content, axis: .vertical) {
                Text("Welcome!")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .font(.system(size: textSize))
            .foregroundStyle(.white)
            .padding(.top)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear { rebuildCache() }
        .onChange(of: imageItems) { _, _ in
            rebuildCache()
        }
    }

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
