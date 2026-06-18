//
//  HomeView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/13/26.
//

import SwiftUI
import SwiftData

// MARK: - Navigation Intent

/// Bundles a newly created note with the initial action to auto-trigger in the editor.
private struct ActiveNoteIntent: Equatable, Identifiable, Hashable {
    let id = UUID()
    let note: NotesModel
    let action: NoteInitialAction
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<NotesModel> { !$0.isImportant },
        sort: [SortDescriptor(\.lastEdited, order: .reverse)]
    )
    private var notes: [NotesModel]

    @Query(
        filter: #Predicate<NotesModel> { $0.isImportant },
        sort: [SortDescriptor(\.lastEdited, order: .reverse)]
    )
    private var pinnedNotes: [NotesModel]

    @State private var activeNoteIntent: ActiveNoteIntent? = nil
    @State private var searchText: String = ""

    // MARK: - Filtered Queries

    private var filteredNotes: [NotesModel] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            $0.noteTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.noteContent.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var filteredPinnedNotes: [NotesModel] {
        guard !searchText.isEmpty else { return pinnedNotes }
        return pinnedNotes.filter {
            $0.noteTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.noteContent.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var isEmpty: Bool {
        notes.isEmpty && pinnedNotes.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                // Main content column
                VStack(spacing: 0) {
                    searchBar

                    if isEmpty {
                        Spacer()
                        EmptyStateView()
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                // Pinned section
                                if !filteredPinnedNotes.isEmpty {
                                    sectionHeader("PINNED")
                                    NotesSectionView(notes: filteredPinnedNotes)
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 16)
                                }

                                // Others section
                                if !filteredNotes.isEmpty {
                                    if !filteredPinnedNotes.isEmpty {
                                        sectionHeader("OTHERS")
                                    }
                                    NotesSectionView(notes: filteredNotes)
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 16)
                                }
                            }
                            // Bottom clearance so last card doesn't hide behind the floating pill
                            .padding(.bottom, 110)
                        }
                    }
                }

                // Floating liquid-glass pill — overlaid above content
                VStack {
                    Spacer()
                    HomeBottomNavBar { action in
                        handleBottomNavAction(action)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .preferredColorScheme(.dark)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $activeNoteIntent) { intent in
                NotesPageView(note: intent.note, initialAction: intent.action)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tertiary)
                .font(.system(size: 15))

            TextField("Search your notes", text: $searchText)
                .font(.body)
                .submitLabel(.search)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(white: 0.14), in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    // MARK: - Section Header

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .tracking(1.5)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }


    // MARK: - Actions

    private func createNewNote(action: NoteInitialAction = .none) {
        let newNote = NotesModel(
            bgImage: nil,
            noteTitle: "",
            noteTypeCase: .note,
            noteContent: "",
            isImportant: false,
            notePageColor: .defaultColor,
            contentSize: 16,
            imageItems: []
        )
        modelContext.insert(newNote)
        activeNoteIntent = ActiveNoteIntent(note: newNote, action: action)
    }

    /// Routes each bottom-nav shortcut to its corresponding note action.
    private func handleBottomNavAction(_ action: HomeBottomNavAction) {
        switch action {
        case .newTextNote:    createNewNote(action: .none)
        case .newDrawingNote: createNewNote(action: .openDrawing)
        case .newVoiceNote:   createNewNote(action: .none)   // Reserved
        case .newImageNote:   createNewNote(action: .openImagePicker)
        }
    }
}

// MARK: - Preview

#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: NotesModel.self, configurations: config)
        for note in NotesDummyData.dummyNotes {
            container.mainContext.insert(note)
        }
        return container
    }()

    return HomeView()
        .modelContainer(container)
}
