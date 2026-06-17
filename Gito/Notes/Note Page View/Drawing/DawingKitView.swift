//
//  DawingKitView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI
import PencilKit

struct DrawingEditorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale

    var existingDrawingData: Data? = nil
    // Returning both: jpeg for display, raw PKDrawing data for re-editing
    var onSave: (Data, Data) -> Void

    @State private var drawing = PKDrawing()

    init(existingDrawingData: Data? = nil, onSave: @escaping (Data, Data) -> Void) {
        self.existingDrawingData = existingDrawingData
        self.onSave = onSave

        if let data = existingDrawingData,
           let loaded = try? PKDrawing(data: data) {
            _drawing = State(wrappedValue: loaded)
        } else {
            _drawing = State(wrappedValue: PKDrawing())
        }
    }

    var body: some View {
        NavigationStack {
            CanvasView(drawing: $drawing)
                .ignoresSafeArea()
                .navigationTitle("Drawing")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveDrawing() }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button("Clear", role: .destructive) {
                            drawing = PKDrawing()
                        }
                    }
                }
                .background(Color(.systemBackground))
        }
    }

    private func saveDrawing() {
        // 1. Raw PKDrawing data — used for re-editing later
        let rawData = drawing.dataRepresentation()

        // 2. Render to JPEG — used for display in note
        let bounds = drawing.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: 300, height: 300)
            : drawing.bounds.insetBy(dx: -20, dy: -20)

        let image = drawing.image(from: bounds, scale: displayScale)

        guard let jpegData = image.jpegData(compressionQuality: 0.9) else { return }

        // Pass both back
        onSave(jpegData, rawData)
        dismiss()
    }
}
