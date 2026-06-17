//
//  DummyData.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import Foundation

struct NotesDummyData {
    static var dummyNotes: [NotesModel] {
        [
            NotesModel(
                bgImage: .image1, noteTitle: "Morning Routine",
                noteCreate: Date(),
                noteTypeCase: .today,
                noteContent: "Drink water, stretch for 10 minutes, and review daily goals.",
                isImportant: true,
                notePageColor: .coral,
                contentSize: 16
            ),
            NotesModel(
                bgImage: .image2, noteTitle: "Project Roadmap",
                noteCreate: Date().addingTimeInterval(-86400), // 1 day ago
                noteTypeCase: .plans,
                noteContent: "Phase 1: Design UI. Phase 2: Implement SwiftData. Phase 3: Beta testing.",
                isImportant: true,
                notePageColor: .sage,
                contentSize: 14
            ),
            NotesModel(
                bgImage: .image3, noteTitle: "Grocery List",
                noteCreate: Date().addingTimeInterval(-172800), // 2 days ago
                noteTypeCase: .task,
                noteContent: "- Almond milk\n- Avocados\n- Whole wheat bread\n- Coffee beans",
                isImportant: false,
                notePageColor: .lemonYellow,
                contentSize: 15
            ),
            NotesModel(
                noteTitle: "App Idea Notes",
                noteCreate: Date().addingTimeInterval(-259200), // 3 days ago
                noteTypeCase: .note,
                noteContent: "A minimalist markdown editor that syncs seamlessly via CloudKit.",
                isImportant: false,
                notePageColor: .rustWood,
                contentSize: 18
            ),
            NotesModel(
                noteTitle: "Client Meeting",
                noteCreate: Date().addingTimeInterval(-345600), // 4 days ago
                noteTypeCase: .remember,
                noteContent: "Remember to ask John about the updated brand guidelines and asset folder.",
                isImportant: false,
                notePageColor: .evergreenMoss,
                contentSize: 14
            ),
            NotesModel(
                noteTitle: "Workout Routine",
                noteCreate: Date().addingTimeInterval(-432000), // 5 days ago
                noteTypeCase: .today,
                noteContent: "Push day: Bench press, Overhead press, Lateral raises, and Tricep dips.",
                isImportant: false,
                notePageColor: .lemonGreen,
                contentSize: 16
            )
        ]
    }
}
