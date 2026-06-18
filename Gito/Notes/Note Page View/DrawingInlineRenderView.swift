//
//  DrawingInlineRenderView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI
import PencilKit

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
