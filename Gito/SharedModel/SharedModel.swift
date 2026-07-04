//
//  SharedModel.swift
//  Gito
//
//  Created by Vivek Chahal on 03/07/26.
//

import Foundation
import SwiftData

public enum SharedModelContainer {
    public static var container: ModelContainer = {
        let schema = Schema([
            NotesModel.self
        ])

        let modelConfiguration: ModelConfiguration

        // Attempt to find the App Group container
        if let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.org.vkc.Gito")?
            .appendingPathComponent("GitoData.sqlite") {

            print("✅ SharedModelContainer: Connected to App Group Storage at \(groupURL.path)")
            modelConfiguration = ModelConfiguration(url: groupURL)
        } else {
            // Fallback gracefully to the local target sandbox instead of crashing with fatalError
            print("⚠️ SharedModelContainer: App Group not entitled — using local sandbox. Widget will NOT see this data!")
            modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
