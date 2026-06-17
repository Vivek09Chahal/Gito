//
//  ColorView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI

struct ColorView: View {

    @Binding var colorSelected: pageColors
    @Binding var bgSelected: bgImage?

    var body: some View {
        GeometryReader { geo in

            let itemSize: CGFloat = geo.size.width / 8

            VStack(alignment: .leading, spacing: 16) {

                Text("Colors")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                ColorPickerWidget(
                    selectedColor: $colorSelected,
                    itemSize: itemSize
                )

                Text("Background")
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.white)

                BackgroundPickerWidget(
                    selectedBackground: $bgSelected,
                    itemSize: itemSize
                )
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorSelected.pageColor.opacity(0.7))
            .animation(.easeInOut(duration: 0.25), value: colorSelected)
        }
    }
}
