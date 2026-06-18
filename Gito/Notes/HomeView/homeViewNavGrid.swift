//
//  NotesSectionView.swift
//  Gito
//
//  Refactored from homeViewNavGrid.swift.
//  Renders a two-column staggered masonry grid (Google Keep style).
//

import SwiftUI
import SwiftData

/// Distributes notes across two columns for a natural staggered/masonry layout.
struct NotesSectionView: View {
    @Environment(\.modelContext) private var modelContext
    var notes: [NotesModel]

    // Split notes into left and right columns by index
    private var leftColumn: [NotesModel] {
        stride(from: 0, to: notes.count, by: 2).map { notes[$0] }
    }

    private var rightColumn: [NotesModel] {
        stride(from: 1, to: notes.count, by: 2).map { notes[$0] }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            noteColumn(leftColumn)
            noteColumn(rightColumn)
        }
    }

    @ViewBuilder
    private func noteColumn(_ columnNotes: [NotesModel]) -> some View {
        LazyVStack(spacing: 10) {
            ForEach(columnNotes, id: \.id) { note in
                NavigationLink {
                    NotesPageView(note: note)
                } label: {
                    NoteCardView(note: note)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    // Pin / Unpin
                    Button {
                        note.isImportant.toggle()
                        try? modelContext.save()
                    } label: {
                        Label(
                            note.isImportant ? "Unpin" : "Pin",
                            systemImage: note.isImportant ? "pin.slash.fill" : "pin.fill"
                        )
                    }

                    Divider()

                    // Destructive delete
                    Button(role: .destructive) {
                        modelContext.delete(note)
                    } label: {
                        Label("Delete Note", systemImage: "trash.fill")
                    }
                }
            }
        }
    }
}
