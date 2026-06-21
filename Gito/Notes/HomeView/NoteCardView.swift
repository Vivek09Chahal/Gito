//
//  NoteCardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import SwiftData
import PencilKit

struct NoteCardView: View {
    let note: NotesModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !note.noteTitle.isEmpty {
                Text(note.noteTitle)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .lineLimit(5)
                    .padding(.vertical)
            } else {
                Text("No TITLE")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .lineLimit(5)
                    .padding(.vertical)

            }

            if !note.noteContent.isEmpty {
                Text(note.noteContent)
                    .font(.caption)
                    .lineLimit(10)
                    .foregroundStyle(foregroundPrimary.opacity(0.72))
                    .multilineTextAlignment(.leading)
            }

            if note.noteTitle.isEmpty && note.noteContent.isEmpty {
                Text("Empty note")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
            Spacer()

            HStack {
                if !note.imageItems.isEmpty {
                    HStack {
                        // Use .prefix(4) to limit the array to a maximum of 4 items safely
                        ForEach(note.imageItems.prefix(2), id: \.id) { item in
                            if let uiImage = UIImage(data: item.jpegData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 35)
                            }
                        }
                    }
                }

                if !note.drawingItems.isEmpty {
                    ForEach(Array(note.drawingItems.prefix(2).enumerated()), id: \.element.id) { index, item in
                        if let pkDrawing = try? PKDrawing(data: item.rawDrawingData) {
                            DrawingInlineRenderView(drawing: pkDrawing)
                                .frame(width: 25, height: 35)
                                .background(Color.black)
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Text(note.lastEdited, style: .date)
                    .font(.caption2)
                    .foregroundStyle(foregroundPrimary.opacity(0.4))
            }
            .padding(.top, 10)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 200)
        .foregroundStyle(foregroundPrimary)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 0.5)
        )
        .overlay(alignment: .topTrailing) {
            if note.isImportant {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.yellow.opacity(0.85))
                    .rotationEffect(.degrees(45))
                    .padding(8)
            }
        }
    }

    private var hasBackgroundImage: Bool {
        guard let name = note.bgImage?.imageName else { return false }
        return !name.isEmpty
    }

    private var foregroundPrimary: Color {
        hasBackgroundImage ? .white : .primary
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let imageName = note.bgImage?.imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.48))
        } else {
            note.notePageColor.pageColor
        }
    }
}
