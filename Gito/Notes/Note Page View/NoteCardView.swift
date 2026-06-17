//
//  NoteCardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import SwiftData

struct NoteCardView: View {

    var isHorizontalScroll: Bool = false
    let note: NotesModel
    var screenSize: CGSize

    var cardHeight: CGFloat {
        isHorizontalScroll ? screenSize.height * 0.37 : screenSize.height * 0.20
    }

    var cardWidth: CGFloat {
        isHorizontalScroll ? screenSize.width * 0.58 : screenSize.width
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.noteTypeCase.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                Spacer()
            }

            Text(note.noteTitle)
                .font(.headline)
                .fontDesign(.rounded)
                .lineLimit(1)

            Text(note.noteContent)
                .font(.system(size: note.contentSize))
                .lineLimit(isHorizontalScroll ? 6 : 4)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            Text(note.lastEdited, style: .date)
                .font(.caption2)
        }
        .padding()
        .foregroundColor(hasBackgroundImage ? .white : .primary)
        .frame(width: isHorizontalScroll ? cardWidth : nil, height: cardHeight, alignment: .leading)
        .frame(maxWidth: isHorizontalScroll ? cardWidth : .infinity, alignment: .leading)
        .background(
            cardBackground
                .cornerRadius(24)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - Helper Computed Properties
    private var hasBackgroundImage: Bool {
        if let name = note.bgImage?.imageName { return !name.isEmpty }
        return false
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let imageName = note.bgImage?.imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: isHorizontalScroll ? cardWidth : screenSize.width - 32, height: cardHeight)
                .overlay(Color.black.opacity(0.2))
        } else {
            note.notePageColor.pageColor
        }
    }
}

