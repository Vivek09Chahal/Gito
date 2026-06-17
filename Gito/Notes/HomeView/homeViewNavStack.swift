//
//  homeViewNavStack.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import SwiftData

struct homeViewNavStack: View {

    @Environment(\.modelContext) private var modelContext
    var notes: [NotesModel]
    var screenSize: CGSize

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(notes, id: \.id) { note in
                NavigationLink {
                    NotesPageView(note: note)
                } label: {
                    NoteCardView(note: note, screenSize: screenSize)
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(note)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
    }
}
