//
//  AppIntent.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 25/06/26.
//

import Foundation
import AppIntents
import SwiftData

struct NoteEntity: AppEntity {
    let id: UUID
    let title: String
    let content: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Note"
    static var defaultQuery = NoteQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title.isEmpty ? "Untitled Note" : title)")
    }
}

struct NoteQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [NoteEntity.ID]) async throws -> [NoteEntity] {
        let context = SharedContainer.sharedContext
        let descriptor = FetchDescriptor<NotesModel>(predicate: #Predicate { identifiers.contains($0.id) })
        let notes = try context.fetch(descriptor)
        return notes.map { NoteEntity(id: $0.id, title: $0.noteTitle, content: $0.noteContent) }
    }

    @MainActor
    func suggestedEntities() async throws -> [NoteEntity] {
        let context = SharedContainer.sharedContext
        let descriptor = FetchDescriptor<NotesModel>(sortBy: [SortDescriptor(\.lastEdited, order: .reverse)])
        let notes = try context.fetch(descriptor)
        return notes.map { NoteEntity(id: $0.id, title: $0.noteTitle, content: $0.noteContent) }
    }
}

// Configuration Intent for the Single Note Widget
struct SelectNoteIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Note"
    static var description: IntentDescription = "Choose a specific note to display on your Home Screen."

    @Parameter(title: "Note")
    var selectedNote: NoteEntity?
}

// MARK: - Shared SwiftData Container Helper
public enum SharedContainer {
    /// The App Group identifier must match what is configured in both targets'
    /// Signing & Capabilities → App Groups entitlement.
    static let appGroupIdentifier = "group.org.vkc.Gito"

    @MainActor
    public static let sharedContext: ModelContext = {
        let schema = Schema([NotesModel.self])

        // Try to resolve the shared App Group container URL.
        // If the App Group capability is not yet enabled in Xcode, fall back to
        // an in-memory store so the widget compiles and runs without crashing.
        let config: ModelConfiguration
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            let storeURL = groupURL.appendingPathComponent("Gito.sqlite")
            config = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            // Fallback: in-memory (widget will show empty state)
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        }

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            return container.mainContext
        } catch {
            fatalError("Failed to initialize shared ModelContainer: \(error)")
        }
    }()
}
