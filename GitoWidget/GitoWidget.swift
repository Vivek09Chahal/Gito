//
//  GitoWidget.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 03/07/26.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// MARK: - Timeline Provider
/// The `Provider` acts as the brain of the widget. It determines when the widget should update
/// and what data (timeline entries) it should display at any given time.
struct Provider: AppIntentTimelineProvider {

    // Thread-safe access to the shared database context on the MainActor
    /// A computed property that fetches the SwiftData model context safely on the main thread,
    /// allowing the widget to query the app's shared database.
    @MainActor
    private var context: ModelContext {
        SharedModelContainer.container.mainContext
    }

    /// Provides a temporary 'mock' entry used when the widget is rendering a placeholder state
    /// (e.g., while loading or appearing in the widget gallery).
    func placeholder(in context: Context) -> GitoEntry {
        GitoEntry(date: Date(), configuration: ConfigurationAppIntent(), recentNotes: [], pinnedNote: nil)
    }

    /// Generates a snapshot entry used for transient situations, like showing the widget in the
    /// widget editing library where immediate data is preferred over a full timeline.
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> GitoEntry {
        await MainActor.run { buildEntry(for: configuration) }
    }

    /// Creates the actual timeline of data updates. This defines what data the widget displays *now* /// and tells iOS when to schedule the next background update (in this case, 15 minutes from now).
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<GitoEntry> {
        let entry = await MainActor.run { buildEntry(for: configuration) }

        // Schedule the next update 15 minutes into the future
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 3, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    // MARK: - Data Fetching

    /// Main logic selector: Determines whether the widget should fetch and show a specific pinned note
    /// chosen by the user, or default to fetching and showing a list of recent notes.
    @MainActor
    private func buildEntry(for configuration: ConfigurationAppIntent) -> GitoEntry {
        // Check if the user selected a note in the widget settings configuration
        if let selected = configuration.selectedNote,
           let freshNote = fetchNote(id: selected.id) {
            // Success: Return an entry containing just the live, pinned note
            return GitoEntry(date: Date(), configuration: configuration, recentNotes: [], pinnedNote: freshNote)
        }

        // Fallback/Default: Fetch and return the latest list of modified notes
        let recentNotes = fetchLatestNotes()
        return GitoEntry(date: Date(), configuration: configuration, recentNotes: recentNotes, pinnedNote: nil)
    }

    /// Queries the SwiftData container for a single specific note matching a unique ID string.
    /// Returns `nil` if the ID is invalid or if the note was deleted from the main app database.
    @MainActor
    private func fetchNote(id: String) -> NotesModel? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        // Set up a database query filtering by the note's UUID
        let descriptor = FetchDescriptor<NotesModel>(
            predicate: #Predicate<NotesModel> { $0.id == uuid }
        )
        return try? context.fetch(descriptor).first
    }

    /// Queries the SwiftData container to retrieve the 3 most recently modified notes,
    /// sorted in descending order based on their `lastEdited` timestamp.
    @MainActor
    private func fetchLatestNotes() -> [NotesModel] {
        // Set up a database query sorted so the most recently edited notes come first
        let descriptor = FetchDescriptor<NotesModel>(
            sortBy: [SortDescriptor(\.lastEdited, order: .reverse)]
        )
        do {
            let allNotes = try context.fetch(descriptor)
            // Limit the result array to a maximum of 3 items to fit the widget canvas size
            return Array(allNotes.prefix(3))
        } catch {
            print("GitoWidget failed to pull notes context: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Timeline Entry
/// The data model encapsulation that WidgetKit expects. It pairs a specific point in time (`date`)
/// with all the payload data needed to draw the UI for that moment.
struct GitoEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let recentNotes: [NotesModel]
    /// Non-nil only when the user configured this widget to pin a single note.
    let pinnedNote: NotesModel?
}

// MARK: - Widget View
/// The main SwiftUI view tree that dictates the physical appearance of the widget on the user's home screen.
struct GitoWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family // Detects size: .systemSmall or .systemMedium

    var body: some View {
        Group {
            // Branch the UI layout depending on whether a note is pinned or not
            if let pinnedNote = entry.pinnedNote {
                pinnedNoteView(pinnedNote)
            } else {
                recentNotesView
            }
        }
        .containerBackground(.fill.tertiary, for: .widget) // Provides standard background padding compatibility for iOS 17+
    }

    // MARK: - Pinned Single Note Layout
    /// A helper view function that builds a detailed, text-heavy view layout optimized
    /// for reading the expanded title and body contents of a single chosen note.
    private func pinnedNoteView(_ note: NotesModel) -> some View {
        // Wraps the entire view layout in a deep link URL so tapping it opens this exact note inside the app
        Link(destination: URL(string: "gito://note?id=\(note.id.uuidString)")!) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(note.notePageColor.pageColor)
                        .frame(width: 8, height: 8)

                    Text(note.noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Note" : note.noteTitle)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer()
                }

                if !note.noteContent.isEmpty {
                    Text(note.noteContent)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        // Adjusts visible text rows dynamically depending on if the widget size is small or medium
                        .lineLimit(family == .systemSmall ? 4 : 8)
                }

                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Notes List Layout
    /// A helper computed view property that designs a compact, 3-row stacked list view,
    /// complete with dynamic states for empty database checks.
    private var recentNotesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Widget Title Header
            HStack {
                Text("Gito Notes")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 2)

            // Dynamic content rendering block
            if entry.recentNotes.isEmpty {
                // Empty State Subview: Displayed if there are no notes in the app database
                VStack(spacing: 4) {
                    Spacer()
                    Text("No notes found")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("Tap to create one!")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            } else {
                // Data State List Loop: Dynamically generates a tappable row layout for up to 3 recent notes
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.recentNotes, id: \.id) { note in
                        // Individual Deep Link wrapper per row
                        Link(destination: URL(string: "gito://note?id=\(note.id.uuidString)")!) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(note.notePageColor.pageColor)
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(note.noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Note" : note.noteTitle)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    if !note.noteContent.isEmpty {
                                        Text(note.noteContent)
                                            .font(.system(size: 10))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Widget Definition
/// The main configuration declaration entry point for the system. This registers the widget extension
/// into iOS, setting up its system types, text identifiers, and allowable display sizes.
struct GitoWidget: Widget {
    let kind: String = "GitoWidget" // A unique system string identifier for managing updates

    var body: some WidgetConfiguration {
        // AppIntentConfiguration links user-customizable interactive intent selections directly to our Provider logic
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GitoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Gito Notes")
        .description("Pin a specific note or view your recent notes.")
        .supportedFamilies([.systemSmall, .systemMedium]) // Constrains user options to small or medium home screen grid cells
    }
}

//
/// Extension layer targeting the configuration intent, defining hardcoded initial structures
/// to quickly simulate UI configurations during developer preview phases.
extension ConfigurationAppIntent {
    /// Simulates a standard layout intent setup where no specific single item selection was chosen.
    fileprivate static var recentNotes: ConfigurationAppIntent {
        ConfigurationAppIntent()
    }

    /// Simulates an active configuration setup targeting a mock pinned item entity.
    fileprivate static var pinnedNote: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.selectedNote = NoteAppEntity(
            id: UUID().uuidString,
            title: "Shopping List",
            content: "Apples, Milk, Eggs, Bread, Coffee",
            colorName: pageColors.coral.rawValue
        )
        return intent
    }
}

// MARK: - Preview
/// Render block used strictly by Xcode Canvas to generate mock canvas previews
/// for checking real-time layout rendering variations across the small layout family option.
#Preview(as: .systemSmall) {
    GitoWidget()
} timeline: {
    // Canvas Preview State 1: A simulated pinned item widget viewport
    GitoEntry(
        date: .now,
        configuration: .pinnedNote,
        recentNotes: [],
        pinnedNote: NotesModel(noteTitle: "Shopping List", noteContent: "Apples, Milk, Eggs, Bread, Coffee", isImportant: false, notePageColor: .coral, contentSize: 14)
    )
    // Canvas Preview State 2: A simulated generic list widget viewport populated with data lines
    GitoEntry(
        date: .now,
        configuration: .recentNotes,
        recentNotes: [
            NotesModel(noteTitle: "Shopping List", noteContent: "Apples, Milk, Eggs", isImportant: false, notePageColor: .coral, contentSize: 14),
            NotesModel(noteTitle: "App Ideas", noteContent: "Build an awesome notes app", isImportant: true, notePageColor: .lemonGreen, contentSize: 14)
        ],
        pinnedNote: nil
    )
}
