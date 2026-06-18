//
//  EntryScreenView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/10/26.
//

import SwiftUI
import SwiftData

struct EntryScreenView: View {
    @AppStorage("firstLaunch") private var isFirstLaunch = true
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if isFirstLaunch {
                OnboardView(onFinished: {
                    isFirstLaunch = false
                })
            } else {
                HomeView(modelContext: modelContext)
            }
        }
    }
}
