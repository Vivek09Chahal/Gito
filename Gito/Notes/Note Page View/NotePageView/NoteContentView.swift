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
    @State private var previousContent: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Image Gallery
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
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }

            // MARK: - Main Editor Area
            VStack(alignment: .leading, spacing: 0) {
                TextField(text: $content, axis: .vertical) {
                    Text("Start writing…")
                        .font(.system(size: textSize))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .font(.system(size: textSize))
                .foregroundStyle(.white)
                .onChange(of: content) { oldValue, newValue in
                    handleAutoNumbering(oldValue: oldValue, newValue: newValue)
                }
            }
            .padding(.top, 12)
        }
        .onAppear {
            previousContent = content
            rebuildCache()
        }
        .onChange(of: imageItems) { _, _ in rebuildCache() }
    }

    // MARK: - Auto-Numbering Logic
    private func handleAutoNumbering(oldValue: String, newValue: String) {
        guard newValue.count == oldValue.count + 1,
              newValue.hasSuffix("\n") else { return }

        let lines = newValue.components(separatedBy: "\n")
        guard lines.count >= 2 else { return }
        let previousLine = lines[lines.count - 2]

        let pattern = #"^(\d+)([\.\)])\s"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                  in: previousLine,
                  range: NSRange(previousLine.startIndex..., in: previousLine)
              ) else { return }

        guard let numberRange = Range(match.range(at: 1), in: previousLine),
              let separatorRange = Range(match.range(at: 2), in: previousLine),
              let currentNumber = Int(previousLine[numberRange]) else { return }

        let separator = String(previousLine[separatorRange])
        let fullPrefix = "\(currentNumber)\(separator) "

        if previousLine == fullPrefix.trimmingCharacters(in: .init(charactersIn: "\n")) {
            var updated = newValue
            updated = String(updated.dropLast())
            if updated.hasSuffix("\n" + previousLine) {
                let removeCount = previousLine.count + 1
                updated = String(updated.dropLast(removeCount))
            } else if updated == previousLine {
                updated = ""
            }
            content = updated
            return
        }

        let nextNumber = currentNumber + 1
        let nextPrefix = "\(nextNumber)\(separator) "
        content = newValue + nextPrefix
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
