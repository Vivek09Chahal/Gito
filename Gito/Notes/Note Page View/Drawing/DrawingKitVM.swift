//
//  DrawingKitVM.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import UIKit
import SwiftUI
import PencilKit

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawing = drawing
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.delegate = context.coordinator
        context.coordinator.canvasView = canvasView

        // Defer until view is in window hierarchy so tool picker attaches correctly
        DispatchQueue.main.async {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            context.coordinator.toolPicker = toolPicker
            canvasView.becomeFirstResponder()
        }

        return canvasView
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        // Only sync the drawing if it changed externally (e.g. loading an existing note)
        if canvasView.drawing != drawing {
            canvasView.drawing = drawing
        }
        // PKToolPicker is intentionally managed only in makeUIView / the deferred block above
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView
        var toolPicker: PKToolPicker?
        var canvasView: PKCanvasView?

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

