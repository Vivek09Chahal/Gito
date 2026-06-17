//
//  DrawingKitView.swift
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
    var onSave: (Data, Data) -> Void

    @State private var drawing = PKDrawing()

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
                .task(id: existingDrawingData) {
                    if let data = existingDrawingData,
                       let loadedDrawing = try? PKDrawing(data: data) {
                        self.drawing = loadedDrawing
                    }
                }
        }
    }

    private func saveDrawing() {
        let rawData = drawing.dataRepresentation()
        let dynamicBounds = drawing.bounds

        let targetRect: CGRect
        if dynamicBounds.isEmpty || dynamicBounds.width <= 0 || dynamicBounds.height <= 0 {
            targetRect = CGRect(x: 0, y: 0, width: 500, height: 500)
        } else {
            targetRect = dynamicBounds.insetBy(dx: -24, dy: -24)
        }

        let image = drawing.image(from: targetRect, scale: displayScale)
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else { return }

        onSave(jpegData, rawData)
        dismiss()
    }
}
