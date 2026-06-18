//
//  HomeNavModels.swift
//  Gito
//
//  Created by Vivek Chahal on 6/18/26.
//
//  Navigation intent models shared across the HomeView module.
//  Keeping these in a dedicated file prevents accidental deletion.
//

import Foundation

struct ActiveNoteIntent: Equatable, Identifiable, Hashable {
    let id = UUID()
    let note: NotesModel
    let action: NoteInitialAction
}

enum NoteInitialAction: Equatable {
    case none
    case openDrawing
    case openImagePicker
    case openCamera
}

enum HomeBottomNavAction {
    case newTextNote
    case newDrawingNote
    case newVoiceNote
    case newImageNote
}
