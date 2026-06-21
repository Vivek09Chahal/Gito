import Foundation
import SwiftUI // Required for UIImage

struct NotesDummyData {

    // MARK: - Helper Function
    /// Converts an array of asset string names into an array of NoteImageItem structs
    static func createDummyImages(from names: [String]) -> [NoteImageItem] {
        return names.compactMap { imageName in
            guard let uiImage = UIImage(named: imageName),
                  let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
                return nil
            }

            return NoteImageItem(
                id: UUID(),
                jpegData: imageData,
                rawDrawingData: nil,
                type: .photo // Make sure this matches your NoteImageType enum
            )
        }
    }

    // MARK: - Dummy Data
    static var dummyNotes: [NotesModel] {
        [
            NotesModel(
                bgImage: .image1,
                noteTitle: "Morning Routine",
                noteContent: "Drink water, stretch for 10 minutes, and review daily goals.",
                isImportant: true,
                notePageColor: .coral, contentSize: 16,
                imageItems: createDummyImages(from: ["bg1", "bg2", "bg3", "bg4", "bg5"])
            ),
            NotesModel(
                bgImage: .image2,
                noteTitle: "Project Roadmap",
                noteContent: "Phase 1: Design UI. Phase 2: Implement SwiftData. Phase 3: Beta testing.",
                isImportant: true,
                notePageColor: .sage, contentSize: 14,
                imageItems: []
            ),
            NotesModel(
                bgImage: .image3,
                noteTitle: "Grocery List",
                noteContent: "- Almond milk\n- Avocados\n- Whole wheat bread\n- Coffee beans",
                isImportant: false,
                notePageColor: .lemonYellow, contentSize: 15,
                imageItems: []
            ),
            NotesModel(
                noteTitle: "App Idea Notes",
                noteContent: "A minimalist markdown editor that syncs seamlessly via CloudKit.",
                isImportant: false,
                notePageColor: .rustWood, contentSize: 18,
                imageItems: []
            ),
            NotesModel(
                noteTitle: "Client Meeting",
                noteContent: "Remember to ask John about the updated brand guidelines and asset folder.",
                isImportant: false,
                notePageColor: .evergreenMoss, contentSize: 14,
                imageItems: []
            ),
            NotesModel(
                noteTitle: "Workout Routine",
                noteContent: "Push day: Bench press, Overhead press, Lateral raises, and Tricep dips.",
                isImportant: false,
                notePageColor: .lemonGreen, contentSize: 16,
                imageItems: []
            )
        ]
    }
}
