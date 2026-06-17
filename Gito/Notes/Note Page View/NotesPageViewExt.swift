//
//  NotesPageViewExt.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

extension NotesPageView {
    func saveNote() {
        // Avoid saving if both title and context are empty
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
              !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        if let existingNote = note {
            // Update existing note
            existingNote.noteTitle = title
            existingNote.noteContent = context
            existingNote.contentSize = textSize
            existingNote.notePageColor = colorSelected
            existingNote.bgImage = bgSelected
            existingNote.isImportant = isImportant
            existingNote.lastEdited = .now
            existingNote.imageItems = imageItems

        } else {
            // Insert new note
            let newNote = NotesModel(
                noteTitle: title,
                noteCreate: .now,
                noteTypeCase: .note,
                noteContent: context,
                isImportant: isImportant,
                notePageColor: colorSelected,
                contentSize: textSize,
                lastEdited: .now,
                imageItems: imageItems
            )
            newNote.bgImage = bgSelected
            notesContext.insert(newNote)
            // Update the local state to the new note to prevent duplicates on subsequent calls
            self.note = newNote
        }

        try? notesContext.save()
    }

    func handleMenuAction(_ action: NoteMenuAction) {
        switch action {

        case .delete:
            if let existingNote = note {
                notesContext.delete(existingNote)
                try? notesContext.save()
            }
            presentMenuSheet = false
            dismiss()

        case .copy:
            UIPasteboard.general.string = "\(title)\n\n\(context)"
            presentMenuSheet = false

        case .send:
            // Hook into ShareSheet or your send flow here
            presentMenuSheet = false
        }
    }

    func handelOptionsAction(_ action: NoteOptionActions) {
        switch action {
        case .addImage:
            presentOptionSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentPhotosPicker = true
            }

        case .takePhoto:
            presentOptionSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentCamera = true
                // saveNote() removed — note is saved inside the camera capture callback
            }

        case .draw:
            presentOptionSheet = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                editingDrawingIndex = nil
                presentDrawing = true
            }
        }
    }
}
