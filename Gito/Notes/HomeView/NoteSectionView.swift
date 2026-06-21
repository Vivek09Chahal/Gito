//
//  NotesSectionView.swift
//  Gito
//
//  Refactored from homeViewNavGrid.swift.
//

import SwiftUI
import SwiftData

struct NotesSectionView: View {
    @Environment(\.modelContext) private var modelContext

    var notes: [NotesModel]
    var screenSize: CGSize
    var viewModel: AppNavigationViewModel

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

                Button {
                    viewModel.loadActiveNote(note)
                    viewModel.activeNoteIntent = ActiveNoteIntent(note: note, action: .none)
                } label: {
                    // Injected screen frame bounds size rules to match parameters layout definition
                    NoteCardView(note: note)
                }
                .buttonStyle(.plain)
                .contextMenu {
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
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteNote(note)
                        }
                    } label: {
                        Label("Delete Note", systemImage: "trash.fill")
                    }
                }
            }
        }
    }
}
