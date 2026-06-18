//
//  DrawingRepresentView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI
import PencilKit

struct DrawingRepresentView: View {

    @Binding var drawingItems: [NoteDrawingItem]
    @Binding var drawingEditTarget: DrawingEditTarget?
    var saveNote: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(drawingItems.enumerated()), id: \.element.id) { index, item in
                    if let pkDrawing = try? PKDrawing(data: item.rawDrawingData) {
                        ZStack(alignment: .topTrailing) {
                            DrawingInlineRenderView(drawing: pkDrawing)
                                .frame(width: 160, height: 160)
                                .background(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .onTapGesture {
                                    drawingEditTarget = DrawingEditTarget(index: index)
                                }

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
}
