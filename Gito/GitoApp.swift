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
        let schema = Schema([
            NotesModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
