//
//  HomeViewModel.swift
//  Gito
//
//  Created by Vivek Chahal on 6/18/26.
//

import Foundation
import SwiftUI
import SwiftData
import PencilKit
import PhotosUI

@Observable
final class AppNavigationViewModel {
    // Shared Database Environment Context
    private var modelContext: ModelContext

    // ====== HOME VIEW GLOBAL STATES ======
    var searchText: String = ""
    var activeNoteIntent: ActiveNoteIntent? = nil

    // ====== ACTIVE EDITOR LOCAL STATES ======
    var currentEditingNote: NotesModel? = nil
    var editorTitle: String = ""
    var editorContext: String = ""
    var editorTextSize: CGFloat = 30
    var editorColorSelected: pageColors = .defaultColor
    var editorBgSelected: bgImage? = nil
    var editorIsImportant: Bool = false
    var editorImageItems: [NoteImageItem] = []
    var editorDrawingItems: [NoteDrawingItem] = []

    // ====== VOICE / SPEECH-TO-TEXT STATE ======
    var speechManager = SpeechToTextManager()

    // Sheet Status Toggles
    var presentColorSheet: Bool = false
    var presentMenuSheet: Bool = false
    var presentOptionSheet: Bool = false
    var presentPhotosPicker: Bool = false
    var presentCamera: Bool = false
    var drawingEditTarget: DrawingEditTarget? = nil
    var pickerSelections: [PhotosPickerItem] = []

    // ====== RESTORED SHORTCUTS INTENT ROUTER STATE ======
    var editorInitialAction: NoteInitialAction = .none

    // MARK: - Initializer
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Editor State Pipeline Controls
    /// Pre-loads data fields into the view-model before opening the target note layout sheet.
    func loadActiveNote(_ note: NotesModel) {
        self.currentEditingNote = note
        self.editorTitle = note.noteTitle
        self.editorContext = note.noteContent
        self.editorTextSize = note.contentSize
        self.editorColorSelected = note.notePageColor
        self.editorBgSelected = note.bgImage
        self.editorIsImportant = note.isImportant
        self.editorImageItems = note.imageItems
        self.editorDrawingItems = note.drawingItems

        self.editorInitialAction = .none
    }

    func saveNote() {
        let isTitleEmpty = editorTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isContextEmpty = editorContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isNoteCompletelyEmpty = isTitleEmpty && isContextEmpty && editorImageItems.isEmpty && editorDrawingItems.isEmpty

        if isNoteCompletelyEmpty {
            if let existingNote = currentEditingNote {
                modelContext.delete(existingNote)
                try? modelContext.save()
                self.currentEditingNote = nil
            }
            return
        }

        if let existingNote = currentEditingNote {
            existingNote.noteTitle = editorTitle
            existingNote.noteContent = editorContext
            existingNote.contentSize = editorTextSize
            existingNote.notePageColor = editorColorSelected
            existingNote.bgImage = editorBgSelected
            existingNote.isImportant = editorIsImportant
            existingNote.lastEdited = .now
            existingNote.imageItems = editorImageItems
            existingNote.drawingItems = editorDrawingItems
        } else {
            let newNote = NotesModel(
                noteTitle: editorTitle,
                noteContent: editorContext,
                isImportant: editorIsImportant,
                notePageColor: editorColorSelected,
                contentSize: editorTextSize,
                lastEdited: .now,
                imageItems: editorImageItems,
                drawingItems: editorDrawingItems
            )
            newNote.bgImage = editorBgSelected
            modelContext.insert(newNote)
            self.currentEditingNote = newNote
        }

        try? modelContext.save()
    }

    // MARK: - Home Actions
    // MARK: - Home Actions
    func createNewNote(action: NoteInitialAction = .none) {
        let newNote = NotesModel(
            bgImage: nil,
            noteTitle: "",
            noteContent: "",
            isImportant: false,
            notePageColor: .defaultColor,
            contentSize: 16,
            imageItems: []
        )
        modelContext.insert(newNote)

        // 1. Clear out properties and reset old editor states first
        loadActiveNote(newNote)

        // 2. NOW apply your shortcut attachment action so it doesn't get overwritten!
        self.editorInitialAction = action
        activeNoteIntent = ActiveNoteIntent(note: newNote, action: action)
    }

    func handleBottomNavAction(_ action: HomeBottomNavAction) {
        switch action {
        case .newTextNote:    createNewNote(action: .none)
        case .newDrawingNote: createNewNote(action: .openDrawing)
        case .newVoiceNote:   createNewNote(action: .openMic)
        case .newImageNote:   createNewNote(action: .openImagePicker)
        }
    }

    func deleteNote(_ note: NotesModel) {
        withAnimation {
            modelContext.delete(note)
            try? modelContext.save()
        }
    }

    // MARK: - Editor Actions
    func handleMenuAction(_ action: NoteMenuAction, onDismiss: @escaping () -> Void) {
        switch action {
        case .delete:
            if let existingNote = currentEditingNote {
                modelContext.delete(existingNote)
                try? modelContext.save()
            }
            presentMenuSheet = false
            onDismiss()
        case .copy:
            UIPasteboard.general.string = "\(editorTitle)\n\n\(editorContext)"
            presentMenuSheet = false
        case .send:
            presentMenuSheet = false
        }
    }

    func handleOptionsAction(_ action: NoteOptionActions) {
        switch action {
        case .addImage:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.presentPhotosPicker = true }
        case .takePhoto:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.presentCamera = true }
        case .draw:
            let newBlankItem = NoteDrawingItem(rawDrawingData: PKDrawing().dataRepresentation())
            editorDrawingItems.append(newBlankItem)
            drawingEditTarget = DrawingEditTarget(index: editorDrawingItems.count - 1)

        case .mic:
            if speechManager.isRecording {
                // Snapshot the latest transcription *before* stopping so the final
                // partial result is never lost when the recognition task is cancelled.
                let finalText = speechManager.transcribedText
                speechManager.stopRecording()
                editorContext = finalText
            } else {
                speechManager.requestAuthorization { [weak self] granted in
                    guard granted, let self else { return }
                    self.speechManager.startRecording(existingText: self.editorContext)
                }
            }
        }
    }

    func loadSelectedPhotos() {
        guard !pickerSelections.isEmpty else { return }
        Task {
            var newData: [NoteImageItem] = []
            for item in pickerSelections {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    newData.append(NoteImageItem(jpegData: data, rawDrawingData: nil, type: .photo))
                }
            }
            await MainActor.run {
                self.editorImageItems.append(contentsOf: newData)
                self.pickerSelections = []
                self.saveNote()
            }
        }
    }

    @MainActor
    func processInitialAction() async {
        guard editorInitialAction != .none else { return }
        try? await Task.sleep(for: .milliseconds(650))
        guard !Task.isCancelled else { return }

        switch editorInitialAction {
        case .openDrawing:     handleOptionsAction(.draw)
        case .openImagePicker: handleOptionsAction(.addImage)
        case .openCamera:      handleOptionsAction(.takePhoto)
        case .openMic:
            // Request mic + speech permissions, then auto-start recording.
            speechManager.requestAuthorization { [weak self] granted in
                guard granted, let self else { return }
                self.speechManager.startRecording(existingText: self.editorContext)
            }
        case .none: break
        }
        editorInitialAction = .none
    }
}
