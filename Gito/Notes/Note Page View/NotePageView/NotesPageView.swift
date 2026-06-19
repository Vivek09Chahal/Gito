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
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: AppNavigationViewModel

    init(viewModel: AppNavigationViewModel, existingNote: NotesModel? = nil, initialAction: NoteInitialAction = .none) {
        self.viewModel = viewModel
        if let note = existingNote {
            viewModel.loadActiveNote(note)
        }
        viewModel.activeNoteIntent = existingNote != nil ? nil : viewModel.activeNoteIntent
    }

    var body: some View {
        @Bindable var vm = viewModel

        GeometryReader { proxy in
            VStack(alignment: .leading) {
                TextField(text: $vm.editorTitle, axis: .vertical) {
                    Text("TITLE")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

                Divider()
                    .background(.white.opacity(0.3))

                ScrollView {
                    // Unified Drawings container layer
                    if !viewModel.editorDrawingItems.isEmpty {
                        DrawingRepresentView(
                            drawingItems: $vm.editorDrawingItems,
                            drawingEditTarget: $vm.drawingEditTarget,
                            saveNote: { viewModel.saveNote() }
                        )
                    }

                    NoteContentView(
                        content: $vm.editorContext,
                        textSize: $vm.editorTextSize,
                        imageItems: $vm.editorImageItems
                    )
                    // Invisible tap layer: stop recording gracefully before keyboard
                    // takes focus, so the transcribed text is preserved in editorContext.
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            if viewModel.speechManager.isRecording {
                                let finalText = viewModel.speechManager.transcribedText
                                viewModel.speechManager.stopRecording()
                                vm.editorContext = finalText
                            }
                        }
                    )
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)

                Spacer()

                BottomNav(proxy: proxy,
                          presentOptionSheet: $vm.presentOptionSheet,
                          presentColorSheet: $vm.presentColorSheet,
                          presentMenuSheet: $vm.presentMenuSheet,
                          lastEdited: viewModel.currentEditingNote?.lastEdited
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .toolbar {
            ToolbarItem {
                Circle()
                    .fill(viewModel.editorColorSelected.pageColor)
                    .onTapGesture { viewModel.presentColorSheet.toggle() }
                    .frame(width: 35, height: 35)
            }
            ToolbarSpacer(.flexible)
            ToolbarItem {
                Image(systemName: viewModel.editorIsImportant ? "star.fill" : "star")
                    .foregroundStyle(viewModel.editorIsImportant ? .yellow : .white)
                    .onTapGesture { viewModel.editorIsImportant.toggle() }
            }
            ToolbarItem {
                Image(systemName: "square.and.arrow.down.fill")
                    .onTapGesture {
                        viewModel.saveNote()
                        dismiss()
                    }
            }
        }
        .task {
            await viewModel.processInitialAction()
        }
        .background(currentBackgroundView.ignoresSafeArea())
        .overlay(alignment: .bottom) {
            if viewModel.speechManager.isRecording {
                VoiceWaveView(
                    audioLevel: viewModel.speechManager.audioLevel,
                    isRecording: viewModel.speechManager.isRecording
                )
                .padding(.bottom, 100)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture { viewModel.handleOptionsAction(.mic) } // tap the wave to stop dictating
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.speechManager.isRecording)
        .onChange(of: viewModel.speechManager.transcribedText) { _, newValue in
            // Only push live transcription updates while actively recording.
            // Once recording stops (user tapped field or pressed stop), we no longer
            // overwrite editorContext so manual edits are never silently erased.
            guard viewModel.speechManager.isRecording else { return }
            vm.editorContext = newValue
        }
        .onDisappear {
            viewModel.speechManager.stopRecording()
            viewModel.saveNote()
        }
        .sheet(isPresented: $vm.presentColorSheet){
            ColorView(colorSelected: $vm.editorColorSelected, bgSelected: $vm.editorBgSelected)
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $vm.presentMenuSheet) {
            NoteMenuView(action: { viewModel.handleMenuAction($0, onDismiss: { dismiss() }) })
                .presentationDetents([.height(180)])
                .presentationBackground(viewModel.editorColorSelected.pageColor)
        }
        .sheet(isPresented: $vm.presentOptionSheet) {
            NoteOptionsView(action: { selectedAction in
                viewModel.handleOptionsAction(selectedAction)
            })
            .presentationDetents([.height(200)])
            .presentationBackground(viewModel.editorColorSelected.pageColor)
        }
        .photosPicker(isPresented: $vm.presentPhotosPicker, selection: $vm.pickerSelections, maxSelectionCount: 10, matching: .images)
        .onChange(of: vm.pickerSelections) { _, _ in viewModel.loadSelectedPhotos() }
        .fullScreenCover(isPresented: $vm.presentCamera) {
            CustomCameraView { capturedData in
                viewModel.editorImageItems.append(NoteImageItem(jpegData: capturedData, rawDrawingData: nil, type: .photo))
                viewModel.saveNote()
            }
        }
        .fullScreenCover(item: $vm.drawingEditTarget) { target in
            drawingEditorSheet(for: target)
        }
    }

    @ViewBuilder
    private var currentBackgroundView: some View {
        if let currentBg = viewModel.editorBgSelected {
            Image(currentBg.imageName)
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.5))
        } else {
            viewModel.editorColorSelected.pageColor
                .overlay(Color.black.opacity(0.2))
        }
    }

    @ViewBuilder
    private func drawingEditorSheet(for target: DrawingEditTarget) -> some View {
        let existingRaw: Data? = viewModel.editorDrawingItems.indices.contains(target.index) ? viewModel.editorDrawingItems[target.index].rawDrawingData : nil

        DrawingEditorView(existingDrawingData: existingRaw) { _, rawDrawingData in
            viewModel.drawingEditTarget = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if viewModel.editorDrawingItems.indices.contains(target.index) {
                    viewModel.editorDrawingItems[target.index].rawDrawingData = rawDrawingData
                } else {
                    viewModel.editorDrawingItems.append(NoteDrawingItem(rawDrawingData: rawDrawingData))
                }
                viewModel.saveNote()
            }
        }
    }
}
