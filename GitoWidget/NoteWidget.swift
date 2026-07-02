//
//  NoteWidget.swift
//  GitoWidgetExtension
//
//  Created by Vivek Chahal on 25/06/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct SingleNoteProvider: AppIntentTimelineProvider {
    typealias Entry = SingleNoteEntry
    typealias Intent = SelectNoteIntent

    func placeholder(in context: Context) -> SingleNoteEntry {
        SingleNoteEntry(date: Date(), title: "Sample Note", content: "This is a brief preview of your custom chosen text node widget setup.")
    }

    func snapshot(for configuration: SelectNoteIntent, in context: Context) async -> SingleNoteEntry {
        if let selected = configuration.selectedNote {
            return SingleNoteEntry(date: Date(), title: selected.title, content: selected.content)
        }
        return placeholder(in: context)
    }

    func timeline(for configuration: SelectNoteIntent, in context: Context) async -> Timeline<SingleNoteEntry> {
        let entry: SingleNoteEntry
        if let selected = configuration.selectedNote {
            entry = SingleNoteEntry(date: Date(), title: selected.title, content: selected.content)
        } else {
            entry = SingleNoteEntry(date: Date(), title: "No Note Selected", content: "Long-press the widget to choose a note.")
        }

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SingleNoteEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
}

struct SingleNoteWidgetView: View {
    var entry: SingleNoteProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title.isEmpty ? "Untitled Note" : entry.title)
                .font(.system(size: 15, weight: .bold))
                .lineLimit(2)
                .foregroundStyle(.primary)

            Text(entry.content.isEmpty ? "No additional text content..." : entry.content)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(contextualLineLimit)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(.fill.tertiary, for: .widget)
    }

    @Environment(\.widgetFamily) var family
    private var contextualLineLimit: Int {
        switch family {
        case .systemSmall: return 4
        default: return 8
        }
    }
}

struct SingleNoteWidget: Widget {
    let kind: String = "SingleNoteWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectNoteIntent.self, provider: SingleNoteProvider()) { entry in
            SingleNoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Sticky Note View")
        .description("Pin a single important note directly to your home layout configuration.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
