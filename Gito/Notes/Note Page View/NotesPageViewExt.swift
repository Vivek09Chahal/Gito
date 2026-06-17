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
import PencilKit

extension NotesPageView {
    func saveNote() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                !imageItems.isEmpty || !drawingItems.isEmpty else {
            return
        }

        if let existingNote = note {
            existingNote.noteTitle = title
            existingNote.noteContent = context
            existingNote.contentSize = textSize
            existingNote.notePageColor = colorSelected
            existingNote.bgImage = bgSelected
            existingNote.isImportant = isImportant
            existingNote.lastEdited = .now
            existingNote.imageItems = imageItems
            existingNote.drawingItems = drawingItems

        } else {
            let newNote = NotesModel(
                noteTitle: title,
                noteTypeCase: .note,
                noteContent: context,
                isImportant: isImportant,
                notePageColor: colorSelected,
                contentSize: textSize,
                lastEdited: .now,
                imageItems: imageItems,
                drawingItems: drawingItems
            )
            newNote.bgImage = bgSelected
            notesContext.insert(newNote)
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
            presentMenuSheet = false
        }
    }

    func handelOptionsAction(_ action: NoteOptionActions) {
        switch action {
        case .addImage:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentPhotosPicker = true
            }

        case .takePhoto:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.presentCamera = true
            }

        case .draw:
            // Append a new blank sketch placeholder item and present the editor matching its index
            let newBlankItem = NoteDrawingItem(rawDrawingData: PKDrawing().dataRepresentation())
            drawingItems.append(newBlankItem)
            drawingEditTarget = DrawingEditTarget(index: drawingItems.count - 1)
        }
    }
}
