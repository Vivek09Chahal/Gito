//
//  GitoWidget.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 25/06/26.
//

import WidgetKit
import SwiftUI
import SwiftData

struct ListProvider: TimelineProvider {
    typealias Entry = ListEntry

    func placeholder(in context: Context) -> ListEntry {
        ListEntry(date: Date(), notes: [
            NotesModel(noteTitle: "Meeting Notes", noteContent: "Discuss architecture changes", isImportant: true, notePageColor: .defaultColor, contentSize: 14),
            NotesModel(noteTitle: "Groceries", noteContent: "Milk, Eggs, Coffee beans", isImportant: false, notePageColor: .sage, contentSize: 14)
        ])
    }

    @MainActor
    func getSnapshot(in context: Context, completion: @escaping (ListEntry) -> Void) {
        let entries = fetchRecentNotes()
        let entry = ListEntry(date: Date(), notes: entries)
        completion(entry)
    }

    @MainActor
    func getTimeline(in context: Context, completion: @escaping (Timeline<ListEntry>) -> Void) {
        let entries = fetchRecentNotes()
        let entry = ListEntry(date: Date(), notes: entries)

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    @MainActor
    private func fetchRecentNotes() -> [NotesModel] {
        let context = SharedContainer.sharedContext
        let descriptor = FetchDescriptor<NotesModel>(sortBy: [SortDescriptor(\.lastEdited, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }
}

struct ListEntry: TimelineEntry {
    let date: Date
    let notes: [NotesModel]
}

struct NotesListWidgetView: View {
    var entry: ListProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Notes")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1.0)

            if entry.notes.isEmpty {
                Text("No notes found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(entry.notes.prefix(3), id: \.id) { note in
                        Link(destination: URL(string: "gito://note?id=\(note.id.uuidString)")!) {
                            HStack {
                                Circle()
                                    .fill(note.notePageColor.pageColor)
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.noteTitle.isEmpty ? "Untitled" : note.noteTitle)
                                        .font(.system(size: 14, weight: .semibold))
                                        .lineLimit(1)
                                    Text(note.noteContent)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        if note.id != entry.notes.prefix(3).last?.id {
                            Divider()
                        }
                    }
                }
            }
            Spacer()
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct NotesListWidget: Widget {
    let kind: String = "NotesListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ListProvider()) { entry in
            NotesListWidgetView(entry: entry)
        }
        .configurationDisplayName("Recent Notes")
        .description("Keep track of your latest snippets and pinned contents.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
