//
//  ImageAttachmentCell.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI

struct ImageAttachmentCell: View {
    let uiImage: UIImage
    let index: Int
    @Binding var imageItems: [NoteImageItem]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if $imageItems.wrappedValue.indices.contains(index) {
                        $imageItems.wrappedValue.remove(at: index)
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
