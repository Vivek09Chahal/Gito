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

    // Cache decoded UIImages using their unique UUID to prevent index mismatch bugs
    @State private var imageCache: [UUID: UIImage] = [:]

    var body: some View {
        ScrollView {
            // FIX: Remove the hard !imageItems.isEmpty block wrapping the ScrollViewReader.
            // Wrapping it tightly can prevent SwiftUI from initializing the scroll tracking engine on empty states.
            ScrollViewReader { scrollProxy in
                if !imageItems.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(imageItems.enumerated()), id: \.element.id) { index, item in
                                // FIX: Check the cache using the item's stable ID instead of its shifting array index position
                                if let uiImage = imageCache[item.id] {
                                    ImageAttachmentCell(
                                        uiImage: uiImage,
                                        item: item,
                                        index: index,
                                        imageItems: $imageItems,
                                        onEditDrawing: onEditDrawing
                                    )
                                } else {
                                    // Placeholder card while the image data is being decoded in the background
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 160, height: 160)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    // Triggers the auto-scroll smooth sliding animation
                    .onChange(of: imageItems.count) { _, newCount in
                        if newCount > 0, let lastItemId = imageItems.last?.id {
                            withAnimation(.easeOut(duration: 0.35)) {
                                scrollProxy.scrollTo(lastItemId, anchor: .trailing)
                            }
                        }
                    }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        .scrollDismissesKeyboard(.interactively)
        .onAppear { rebuildCache() }
        // FIX: Rebuilds the cache on the main actor immediately when imageItems changes
        .onChange(of: imageItems) { _, _ in rebuildCache() }
    }

    // MARK: - Safe Cache Engine
    private func rebuildCache() {
        var updated: [UUID: UIImage] = [:]

        for item in imageItems {
            // Look up by item ID instead of index position so adding the first element to an empty list works instantly
            if let existing = imageCache[item.id] {
                updated[item.id] = existing
            } else if let decoded = UIImage(data: item.jpegData) {
                updated[item.id] = decoded
            }
        }

        self.imageCache = updated
    }
}

// MARK: - Extracted Child View Cell
struct ImageAttachmentCell: View {
    let uiImage: UIImage
    let item: NoteImageItem
    let index: Int
    @Binding var imageItems: [NoteImageItem]
    var onEditDrawing: (Int) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        // FIX: Access the wrappedValue of the Binding to modify the actual array
                        if $imageItems.wrappedValue.indices.contains(index) {
                            $imageItems.wrappedValue.remove(at: index)
                        }
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .black.opacity(0.6))
                        .font(.title3)
                        .padding(6)
                }

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
