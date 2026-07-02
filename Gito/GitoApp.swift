//
//  GitoApp.swift
//  Gito
//
//  Created by Vivek Chahal on 6/10/26.
//

import SwiftUI
import SwiftData

@main
struct GitoApp: App {
    var container: ModelContainer = {
        let schema = Schema([NotesModel.self])

        // Use the shared App Group container so the widget can read notes.
        // The App Group must be enabled under Signing & Capabilities for both
        // the Gito and GitoWidgetExtension targets with id: group.org.vkc.Gito
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.org.vkc.Gito"
        ) {
            let storeURL = groupURL.appendingPathComponent("Gito.sqlite")
            let config = ModelConfiguration(schema: schema, url: storeURL)
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                // Fall through to default store on schema migration errors etc.
                print("⚠️ Could not open App Group store, falling back: \(error)")
            }
        }

        // Fallback: standard per-app storage (widget won't see these notes)
        let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [fallbackConfig])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            EntryScreenView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
