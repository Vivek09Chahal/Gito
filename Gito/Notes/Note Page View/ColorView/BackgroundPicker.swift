//
//  BackgroundPicker.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI

struct BackgroundPickerWidget: View {

    @Binding var selectedBackground: bgImage?
    let itemSize: CGFloat

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Image(systemName: "square.slash")
                    .resizable()
                    .padding(10)
                    .foregroundStyle(selectedBackground == nil ? .white : .white.opacity(0.6))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: itemSize, height: itemSize)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: selectedBackground == nil ? 3 : 0)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedBackground = nil
                        }
                    }

                ForEach(bgImage.allCases, id: \.self) { bg in
                    Image(bg.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: itemSize, height: itemSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(.white,
                                        lineWidth: selectedBackground == bg ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedBackground = bg
                        }
                }
                .padding(.vertical, 7)
            }
            .padding(.leading, 3)
        }
    }
}
