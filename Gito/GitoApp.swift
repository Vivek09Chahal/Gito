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
    // Use the shared instance
    var container = SharedModelContainer.container

    var body: some Scene {
        WindowGroup {
            EntryScreenView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
