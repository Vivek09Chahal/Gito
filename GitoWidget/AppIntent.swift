//
//  AppIntent.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 03/07/26.
//

import WidgetKit
import AppIntents
import SwiftData

// MARK: - App Entity (lightweight representation of a note for the widget picker)

struct NoteAppEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Note")
    static var defaultQuery = NoteEntityQuery()

    var id: String          // UUID string from the original NotesModel
    var title: String
    var content: String
    var colorName: String   // Raw value of pageColors enum

    var displayRepresentation: DisplayRepresentation {
        let displayTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Note"
            : title
        let subtitle = content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : content
        return DisplayRepresentation(
            title: "\(displayTitle)",
            subtitle: subtitle.map { "\($0)" }
        )
    }
}

// MARK: - Entity Query (fetches ALL notes from the shared SwiftData store)

struct NoteEntityQuery: EntityStringQuery {

    /// Called when the system needs to resolve specific entities by their IDs
    @MainActor
    func entities(for identifiers: [NoteAppEntity.ID]) async throws -> [NoteAppEntity] {
        let context = SharedModelContainer.container.mainContext
        let descriptor = FetchDescriptor<NotesModel>()
        let allNotes = (try? context.fetch(descriptor)) ?? []

        let idSet = Set(identifiers)
        return allNotes
            .filter { idSet.contains($0.id.uuidString) }
            .map { $0.toAppEntity() }
    }

    /// Called when the user types in the search bar — filters notes by title/content
    @MainActor
    func entities(matching string: String) async throws -> [NoteAppEntity] {
        let context = SharedModelContainer.container.mainContext
        let descriptor = FetchDescriptor<NotesModel>(
            sortBy: [SortDescriptor(\.lastEdited, order: .reverse)]
        )
        let allNotes = (try? context.fetch(descriptor)) ?? []

        if string.isEmpty {
            return allNotes.map { $0.toAppEntity() }
        }

        let lowered = string.lowercased()
        return allNotes
            .filter {
                $0.noteTitle.lowercased().contains(lowered) ||
                $0.noteContent.lowercased().contains(lowered)
            }
            .map { $0.toAppEntity() }
    }

    /// Shown as the default list before the user types anything
    @MainActor
    func suggestedEntities() async throws -> [NoteAppEntity] {
        let context = SharedModelContainer.container.mainContext
        let descriptor = FetchDescriptor<NotesModel>(
            sortBy: [SortDescriptor(\.lastEdited, order: .reverse)]
        )
        let allNotes = (try? context.fetch(descriptor)) ?? []
        return allNotes.map { $0.toAppEntity() }
    }
}

// MARK: - Convenience mapping

extension NotesModel {
    func toAppEntity() -> NoteAppEntity {
        NoteAppEntity(
            id: id.uuidString,
            title: noteTitle,
            content: noteContent,
            colorName: notePageColor.rawValue
        )
    }
}

// MARK: - Widget Configuration Intent

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select Note" }
    static var description: IntentDescription { "Choose any note to display on the widget, or leave empty to show your recent notes." }

    @Parameter(title: "Note")
    var selectedNote: NoteAppEntity?
}
