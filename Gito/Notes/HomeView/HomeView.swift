//
//  HomeView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/13/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    // Core database queries
    @Query(filter: #Predicate<NotesModel> { !$0.isImportant }, sort: [SortDescriptor(\.lastEdited, order: .reverse)]) private var notes: [NotesModel]
    @Query(filter: #Predicate<NotesModel> { $0.isImportant }, sort: [SortDescriptor(\.lastEdited, order: .reverse)]) private var pinnedNotes: [NotesModel]

    // Unified Application View-Model Orchestrator State Instance
    @State private var appViewModel: AppNavigationViewModel

    init(modelContext: ModelContext) {
        _appViewModel = State(wrappedValue: AppNavigationViewModel(modelContext: modelContext))
    }

    // Computed properties for dynamic search filtering
    private var filteredNotes: [NotesModel] {
        guard !appViewModel.searchText.isEmpty else { return notes }
        return notes.filter {
            $0.noteTitle.localizedCaseInsensitiveContains(appViewModel.searchText) ||
            $0.noteContent.localizedCaseInsensitiveContains(appViewModel.searchText)
        }
    }

    private var filteredPinnedNotes: [NotesModel] {
        guard !appViewModel.searchText.isEmpty else { return pinnedNotes }
        return pinnedNotes.filter {
            $0.noteTitle.localizedCaseInsensitiveContains(appViewModel.searchText) ||
            $0.noteContent.localizedCaseInsensitiveContains(appViewModel.searchText)
        }
    }

    private var isListEmpty: Bool {
        filteredNotes.isEmpty && filteredPinnedNotes.isEmpty
    }

    var body: some View {
        @Bindable var vm = appViewModel
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    Color.default.ignoresSafeArea()

                    // Content List Layout
                    if isListEmpty {
                        VStack {
                            Spacer()
                            EmptyStateView()
                            Spacer()
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                if !filteredPinnedNotes.isEmpty {
                                    sectionHeader("PINNED")
                                    NotesSectionView(notes: filteredPinnedNotes, screenSize: geo.size, viewModel: appViewModel)
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 16)
                                }

                                if !filteredNotes.isEmpty {
                                    if !filteredPinnedNotes.isEmpty {
                                        sectionHeader("OTHERS")
                                    }
                                    NotesSectionView(notes: filteredNotes, screenSize: geo.size, viewModel: appViewModel)
                                        .padding(.horizontal, 12)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("My Notes")
                .searchable(
                    text: $vm.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search your notes"
                )
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack(spacing: 6) {
                            nativeShortcutButton(icon: "checkmark.square", action: .newTextNote)
                            nativeShortcutButton(icon: "pencil.tip", action: .newDrawingNote)
                            nativeShortcutButton(icon: "mic", action: .newVoiceNote)
                            nativeShortcutButton(icon: "photo", action: .newImageNote)
                        }
                        .padding(3)
                    }

                    ToolbarSpacer(.flexible, placement: .bottomBar)

                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            appViewModel.handleBottomNavAction(.newTextNote)
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .navigationDestination(item: $vm.activeNoteIntent) { intent in
                    let _ = { appViewModel.editorInitialAction = intent.action }()
                    return NotesPageView(viewModel: appViewModel)
                }
                .navigationDestination(for: NotesModel.self) { tappedNote in
                    let _ = appViewModel.loadActiveNote(tappedNote)
                    return NotesPageView(viewModel: appViewModel)
                }
            }
        }
    }

    // MARK: - Local Toolbar Helpers

    @ViewBuilder
    private func nativeShortcutButton(icon: String, action: HomeBottomNavAction) -> some View {
        Button {
            appViewModel.handleBottomNavAction(action)
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: 42, height: 42)
                .contentShape(Circle())
        }
        .buttonStyle(.glassProminent)
        .tint(Color.default)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .tracking(1.5)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    // 1. Create an isolated in-memory container so mock entries never persist to the device disk
    let container: ModelContainer = {
        let schema = Schema([NotesModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: config)

            // 2. Seed your dummy data mock records onto the main thread context
            // Ensure NotesDummyData.dummyNotes is accessible in your preview assets group
            for note in NotesDummyData.dummyNotes {
                container.mainContext.insert(note)
            }
            return container
        } catch {
            fatalError("Failed to configure in-memory preview container: \(error.localizedDescription)")
        }
    }()

    // 3. Inject the live memory mainContext dependency straight into the root view initializer
    return HomeView(modelContext: container.mainContext)
        .modelContainer(container) // Fulfills standard environment SwiftData requirements
}
