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

    // Updated Drawing Kit States
    @State var drawingEditTarget: DrawingEditTarget? = nil
    @State var imageItems: [NoteImageItem] = []
    @State var drawingItems: [NoteDrawingItem] = [] // <-- Track multiple drawings locally
    @FocusState var isTextFieldFocused: Bool

    init(note: NotesModel? = nil) {
        _note = State(wrappedValue: note)
        self.lastEdited = note?.lastEdited

        _title = State(wrappedValue: note?.noteTitle ?? "")
        _context = State(wrappedValue: note?.noteContent ?? "")
        _colorSelected = State(wrappedValue: note?.notePageColor ?? .defaultColor)
        _isImportant = State(wrappedValue: note?.isImportant ?? false)
        _bgSelected = State(wrappedValue: note?.bgImage)
        _imageItems = State(wrappedValue: note?.imageItems ?? [])
        _drawingItems = State(wrappedValue: note?.drawingItems ?? []) // <-- Load saved drawings
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
                    // ====== MULTIPLE DRAWINGS DISPLAY LAYER ======
                    if !drawingItems.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(drawingItems.enumerated()), id: \.element.id) { index, item in
                                    if let pkDrawing = try? PKDrawing(data: item.rawDrawingData) {
                                        ZStack(alignment: .topTrailing) {
                                            // Black background, exact 160x160 photo matches
                                            DrawingInlineRenderView(drawing: pkDrawing)
                                                .frame(width: 160, height: 160)
                                                .background(Color.black)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .onTapGesture {
                                                    drawingEditTarget = DrawingEditTarget(index: index)
                                                }

                                            // Delete asset button
                                            Button {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    if drawingItems.indices.contains(index) {
                                                        drawingItems.remove(at: index)
                                                        saveNote()
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, .black.opacity(0.6))
                                                    .font(.title3)
                                                    .padding(6)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
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

    // ====== EXTRACTION SHEET BUILDER ======
    @ViewBuilder
    private func drawingEditorSheet(for target: DrawingEditTarget) -> some View {
        let existingRaw: Data? = drawingItems.indices.contains(target.index) ? drawingItems[target.index].rawDrawingData : nil

        DrawingEditorView(existingDrawingData: existingRaw) { _, rawDrawingData in
            drawingEditTarget = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if drawingItems.indices.contains(target.index) {
                    // Update existing item array entry
                    drawingItems[target.index].rawDrawingData = rawDrawingData
                } else {
                    // Safety check fallback
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

// Inline renderer element that forcefully busts cache via pure data hashing definitions
struct DrawingInlineRenderView: View {
    let drawing: PKDrawing
    @Environment(\.displayScale) var displayScale

    var body: some View {
        let targetRect = drawing.bounds.insetBy(dx: -16, dy: -16)
        let image = drawing.image(from: targetRect, scale: displayScale)

        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .padding(8)
            .id(drawing.dataRepresentation().hashValue) // Force redraw when stroke hash updates
    }
}
