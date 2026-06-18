//
//  NoteCardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import SwiftData

/// A purely presentational card that renders a single note in the masonry grid.
/// Height is driven by content — no fixed frame — giving the natural staggered effect.
struct NoteCardView: View {
    let note: NotesModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            if !note.noteTitle.isEmpty {
                Text(note.noteTitle)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .lineLimit(5)
                    .padding(.bottom, 5)
            }

            // Content preview
            if !note.noteContent.isEmpty {
                Text(note.noteContent)
                    .font(.caption)
                    .lineLimit(10)
                    .foregroundStyle(foregroundPrimary.opacity(0.72))
                    .multilineTextAlignment(.leading)
            }

            // Empty note placeholder
            if note.noteTitle.isEmpty && note.noteContent.isEmpty {
                Text("Empty note")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }

            // Footer — type tag + date
            HStack {
                Text(note.noteTypeCase.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(foregroundPrimary.opacity(0.4))

                Spacer()

                Text(note.lastEdited, style: .date)
                    .font(.caption2)
                    .foregroundStyle(foregroundPrimary.opacity(0.4))
            }
            .padding(.top, 10)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(foregroundPrimary)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 0.5)
        )
        // Pin badge for important notes
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

    // MARK: - Helpers

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
