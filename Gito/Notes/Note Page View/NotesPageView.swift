//
//  NotesPage.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

//
//   NotesPage.swift
//   Gito
//
//   Created by Vivek Chahal on 6/15/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct NotesPageView: View {

    @Environment(\.modelContext) var notesContext
    @Environment(\.dismiss) var dismiss
    @State var note: NotesModel?

    @State var title: String
    @State var context: String
    @State var textSize: CGFloat = 15
    @State var pageBGColor: pageColors = .defaultColor // PascalCase enum
    @State var presentColorSheet: Bool = false
    @State var isImportant: Bool = false
    var lastEdited: Date?
    @State var presentMenuSheet: Bool = false
    @State var presentOptionSheet: Bool = false

    // Color & BG state
    @State var colorSelected: pageColors
    @State var bgSelected: bgImage?

    @State var picker = photoPicker() // PascalCase component
    @State var presentPhotosPicker: Bool = false
    @State var pickerSelections: [PhotosPickerItem] = []
    @State var presentCamera: Bool = false

    // Drawing kit
    @State var presentDrawing: Bool = false
    @State var editingDrawingIndex: Int? = nil
    @State var imageItems: [NoteImageItem] = []
    @FocusState var isTextFieldFocused: Bool

    // MARK: - Safe Initializer
    init(note: NotesModel? = nil) {
        _note = State(wrappedValue: note)
        self.lastEdited = note?.lastEdited

        // Using wrappedValue ensures standard compiler behavior
        _title = State(wrappedValue: note?.noteTitle ?? "")
        _context = State(wrappedValue: note?.noteContent ?? "")
        _colorSelected = State(wrappedValue: note?.notePageColor ?? .defaultColor)
        _isImportant = State(wrappedValue: note?.isImportant ?? false)
        _bgSelected = State(wrappedValue: note?.bgImage)
        _imageItems = State(wrappedValue: note?.imageItems ?? [])
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

                NoteContentView(
                    content: $context,
                    textSize: $textSize,
                    imageItems: $imageItems,
                    onEditDrawing: { index in
                        editingDrawingIndex = index
                        presentDrawing = true
                    }
                )

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
                    .onTapGesture {
                        presentColorSheet.toggle()
                    }
                    .frame(width: 35, height: 35)
            }
            ToolbarSpacer(.flexible)
            ToolbarItem {
                Image(systemName: isImportant ? "star.fill" : "star")
                    .foregroundStyle(isImportant ? .yellow : .white)
                    .onTapGesture {
                        isImportant.toggle()
                    }
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
        .onDisappear {
            saveNote()
        }
        .sheet(isPresented: $presentColorSheet){
            ColorView(
                colorSelected: $colorSelected,
                bgSelected: $bgSelected
            )
            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $presentMenuSheet) {
            NoteMenuView(action: { action in
                handleMenuAction(action)
            })
            .presentationDetents([.height(180)])
            .presentationBackground(colorSelected.pageColor)
        }
        .sheet(isPresented: $presentOptionSheet) {
            NoteOptionsView(action: { action in
                handelOptionsAction(action)
            })
            .presentationDetents([.height(200)])
            .presentationBackground(colorSelected.pageColor)
        }
        .photosPicker(isPresented: $presentPhotosPicker, selection: $pickerSelections, maxSelectionCount: 10, matching: .images)
        .onChange(of: pickerSelections) { _, newItems in
            loadSelectedPhotos(newItems)
        }
        .fullScreenCover(isPresented: $presentCamera) {
            CustomCameraView { capturedData in
                imageItems.append(NoteImageItem(jpegData: capturedData, rawDrawingData: nil, type: .photo))
                saveNote()
            }
        }
        .fullScreenCover(isPresented: $presentDrawing) {
            drawingEditorContainer
        }
    }

    // MARK: - Background
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

    // MARK: - Drawing
    @ViewBuilder
    private var drawingEditorContainer: some View {
        let existingRaw: Data? = editingDrawingIndex.flatMap { index in
            imageItems.indices.contains(index) ? imageItems[index].rawDrawingData : nil
        }

        DrawingEditorView(existingDrawingData: existingRaw) { jpegData, rawData in
            if let index = editingDrawingIndex {
                imageItems[index].jpegData = jpegData
                imageItems[index].rawDrawingData = rawData
            } else {
                imageItems.append(NoteImageItem(jpegData: jpegData, rawDrawingData: rawData, type: .drawing))
            }
            editingDrawingIndex = nil
            saveNote()
        }
    }
    
    // MARK: - Photo Helper Logic
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
