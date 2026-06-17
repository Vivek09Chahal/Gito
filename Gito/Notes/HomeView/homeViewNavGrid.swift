//
//  homeViewNavGrid.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//


import SwiftUI
import SwiftData

struct homeViewNavGrid: View {

    @Environment(\.modelContext) private var modelContext
    var notes: [NotesModel]
    var screenSize: CGSize

    var body: some View {
        if !notes.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(notes, id: \.id) { note in
                        NavigationLink {
                            NotesPageView(note: note)
                        } label: {
                            NoteCardView(isHorizontalScroll: true, note: note, screenSize: screenSize)
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
                .padding(.vertical) // Moved inside ScrollView — prevents extra outer layout pass
            }
        }
    }
}

