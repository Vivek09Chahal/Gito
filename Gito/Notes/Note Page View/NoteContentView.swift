//
//  NotePhotoView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct NoteContentView: View {
    @Binding var content: String
    @Binding var textSize: CGFloat
    @Binding var imageItems: [NoteImageItem]
    var onEditDrawing: (Int) -> Void

    // Cache decoded UIImages so JPEG blobs aren't decoded on every render
    @State private var imageCache: [Int: UIImage] = [:]

    var body: some View {
        ScrollView {
            if !imageItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(imageItems.enumerated()), id: \.offset) { index, item in
                            if let uiImage = imageCache[index] {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 160, height: 160)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

                                    VStack(spacing: 0) {
                                        Button {
                                            imageItems.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.6))
                                                .font(.title3)
                                                .padding(6)
                                        }

                                        // Only shows for drawings
                                        if item.type == .drawing {
                                            Button {
                                                onEditDrawing(index)
                                            } label: {
                                                Image(systemName: "pencil.circle.fill")
                                                    .foregroundStyle(.white, .black.opacity(0.6))
                                                    .font(.title3)
                                                    .padding(6)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .scrollDismissesKeyboard(.interactively)
        .onAppear { rebuildCache() }
        .onChange(of: imageItems) { rebuildCache() }
    }

    // Decode each JPEG once; only re-decode indices that are new or changed
    private func rebuildCache() {
        var updated: [Int: UIImage] = [:]
        for (index, item) in imageItems.enumerated() {
            if let existing = imageCache[index],
               // Re-use cached image when data pointer is unchanged
               item.jpegData == imageItems[index].jpegData,
               imageCache[index] != nil {
                updated[index] = existing
            } else if let decoded = UIImage(data: item.jpegData) {
                updated[index] = decoded
            }
        }
        imageCache = updated
    }
}
