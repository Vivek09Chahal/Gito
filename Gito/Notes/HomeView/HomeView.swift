//
//  HomeView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/13/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<NotesModel> { !$0.isImportant }, sort: [SortDescriptor(\.lastEdited, order: .reverse)])
    private var notes: [NotesModel]

    @Query(filter: #Predicate<NotesModel> { $0.isImportant }, sort: [SortDescriptor(\.lastEdited, order: .reverse)])
    private var importantNotes: [NotesModel]

    @State private var showMenu = false
    @State private var navigateToNewNote = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .bottomTrailing) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            if notes.isEmpty && importantNotes.isEmpty {
                                EmptyStateView()
                            } else {
                                homeViewNavGrid(notes: importantNotes, screenSize: geo.size)
                                homeViewNavStack(notes: notes, screenSize: geo.size)
                            }
                        }
                    }

                    // Clean FAB Floating Layout using logical standard frames
                    Button {
                        navigateToNewNote = true
                    } label: {
                        Image(systemName: "pencil.and.scribble")
                            .font(.title2)
                            .bold()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.linearGradient(colors: [.indigo, .pink], startPoint: .top, endPoint: .bottom))
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                            .overlay(
                                Circle()
                                    .stroke(.linearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
                .preferredColorScheme(.dark)
                .navigationTitle("My Notes")
                .navigationDestination(isPresented: $navigateToNewNote) {
                    NotesPageView(note: nil)
                        .id(UUID().uuidString)
                }
            }
        }
    }
}
#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: NotesModel.self, configurations: config)

        for note in NotesDummyData.dummyNotes {
            container.mainContext.insert(note)
        }

        return container
    }()

    HomeView()
        .modelContainer(container)
}
