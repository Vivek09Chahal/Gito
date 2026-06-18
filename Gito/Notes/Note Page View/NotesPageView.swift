//
//  NotesPageView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import PhotosUI
import SwiftData
import PencilKit

struct NotesPageView: View {

    @Environment(\.modelContext) var notesContext
    @Environment(\.dismiss) var dismiss
    @State var note: NotesModel?

    @State var title: String
    @State var context: String
    @State var textSize: CGFloat = 15
    @State var pageBGColor: pageColors = .defaultColor
    @State var presentColorSheet: Bool = false
    @State var isImportant: Bool = false
    var lastEdited: Date?
    @State var presentMenuSheet: Bool = false
    @State var presentOptionSheet: Bool = false

    @State var colorSelected: pageColors
    @State var bgSelected: bgImage?

    @State var picker = photoPicker()
    @State var presentPhotosPicker: Bool = false
    @State var pickerSelections: [PhotosPickerItem] = []
    @State var presentCamera: Bool = false

    // Drawing Kit States
    @State var drawingEditTarget: DrawingEditTarget? = nil
    @State var imageItems: [NoteImageItem] = []
    @State var drawingItems: [NoteDrawingItem] = []
    @FocusState var isTextFieldFocused: Bool

    /// Action to auto-trigger once the view has fully appeared (set from HomeView bottom nav).
    @State private var initialAction: NoteInitialAction = .none

    init(note: NotesModel? = nil, initialAction: NoteInitialAction = .none) {
        _note = State(wrappedValue: note)
        self.lastEdited = note?.lastEdited

        _title = State(wrappedValue: note?.noteTitle ?? "")
        _context = State(wrappedValue: note?.noteContent ?? "")
        _colorSelected = State(wrappedValue: note?.notePageColor ?? .defaultColor)
        _isImportant = State(wrappedValue: note?.isImportant ?? false)
        _bgSelected = State(wrappedValue: note?.bgImage)
        _imageItems = State(wrappedValue: note?.imageItems ?? [])
        _drawingItems = State(wrappedValue: note?.drawingItems ?? [])
        _initialAction = State(wrappedValue: initialAction)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading) {
                TextField(text: $title, axis: .vertical) {
                    Text("TITLE")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

                Divider()
                    .background(.white.opacity(0.3))

                ScrollView {
                    // ====== REFACTORED SEPARATE DRAWINGS LAYER ======
                    if !drawingItems.isEmpty {
                        DrawingRepresentView(
                            drawingItems: $drawingItems,
                            drawingEditTarget: $drawingEditTarget,
                            saveNote: { saveNote() }
                        )
                    }

                    NoteContentView(
                        content: $context,
                        textSize: $textSize,
                        imageItems: $imageItems
                    )
                }

                Spacer()

                BottomNav(proxy: proxy,
                          presentOptionSheet: $presentOptionSheet,
                          presentColorSheet: $presentColorSheet,
                          presentMenuSheet: $presentMenuSheet,
                          lastEdited: lastEdited
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem {
                Circle()
                    .fill(colorSelected.pageColor)
                    .onTapGesture { presentColorSheet.toggle() }
                    .frame(width: 35, height: 35)
            }
            ToolbarSpacer(.flexible)
            ToolbarItem {
                Image(systemName: isImportant ? "star.fill" : "star")
                    .foregroundStyle(isImportant ? .yellow : .white)
                    .onTapGesture { isImportant.toggle() }
            }
            ToolbarItem {
                Image(systemName: "square.and.arrow.down.fill")
                    .onTapGesture {
                        saveNote()
                        dismiss()
                    }
            }
        }
        .background(currentBackgroundView.ignoresSafeArea())
        .onDisappear { saveNote() }
        .task {
            // Auto-trigger the requested action after the navigation transition settles
            guard initialAction != .none else { return }
            try? await Task.sleep(for: .milliseconds(650))
            await MainActor.run {
                switch initialAction {
                case .openDrawing:
                    handelOptionsAction(.draw)
                case .openImagePicker:
                    handelOptionsAction(.addImage)
                case .openCamera:
                    handelOptionsAction(.takePhoto)
                case .none:
                    break
                }
                // Clear so it never fires again on re-appear
                initialAction = .none
            }
        }
        .sheet(isPresented: $presentColorSheet){
            ColorView(colorSelected: $colorSelected, bgSelected: $bgSelected)
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $presentMenuSheet) {
            NoteMenuView(action: { handleMenuAction($0) })
                .presentationDetents([.height(180)])
                .presentationBackground(colorSelected.pageColor)
        }
        .sheet(isPresented: $presentOptionSheet) {
            NoteOptionsView(action: { handelOptionsAction($0) })
                .presentationDetents([.height(200)])
                .presentationBackground(colorSelected.pageColor)
        }
        .photosPicker(isPresented: $presentPhotosPicker, selection: $pickerSelections, maxSelectionCount: 10, matching: .images)
        .onChange(of: pickerSelections) { _, newItems in loadSelectedPhotos(newItems) }
        .fullScreenCover(isPresented: $presentCamera) {
            CustomCameraView { capturedData in
                imageItems.append(NoteImageItem(jpegData: capturedData, rawDrawingData: nil, type: .photo))
                saveNote()
            }
        }
        .fullScreenCover(item: $drawingEditTarget) { target in
            drawingEditorSheet(for: target)
        }
    }

    @ViewBuilder
    private var currentBackgroundView: some View {
        if let currentBg = bgSelected {
            Image(currentBg.imageName)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.5))
        } else {
            colorSelected.pageColor
                .overlay(Color.black.opacity(0.2))
        }
    }

    @ViewBuilder
    private func drawingEditorSheet(for target: DrawingEditTarget) -> some View {
        let existingRaw: Data? = drawingItems.indices.contains(target.index) ? drawingItems[target.index].rawDrawingData : nil

        DrawingEditorView(existingDrawingData: existingRaw) { _, rawDrawingData in
            drawingEditTarget = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if drawingItems.indices.contains(target.index) {
                    drawingItems[target.index].rawDrawingData = rawDrawingData
                } else {
                    drawingItems.append(NoteDrawingItem(rawDrawingData: rawDrawingData))
                }
                saveNote()
            }
        }
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) {
        Task {
            var newData: [NoteImageItem] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    newData.append(NoteImageItem(jpegData: data, rawDrawingData: nil, type: .photo))
                }
            }
            await MainActor.run {
                imageItems.append(contentsOf: newData)
                pickerSelections = []
                saveNote()
            }
        }
    }
}
