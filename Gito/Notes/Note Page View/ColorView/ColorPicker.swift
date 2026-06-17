//
//  ColorWidgetView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/17/26.
//

import SwiftUI

struct ColorPickerWidget: View {

    @Binding var selectedColor: pageColors
    let itemSize: CGFloat

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(pageColors.allCases, id: \.self) { colorOption in
                    Circle()
                        .fill(colorOption.pageColor)
                        .frame(width: itemSize, height: itemSize)
                        .overlay(
                            Circle()
                                .stroke(.white,
                                        lineWidth: selectedColor == colorOption ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = colorOption
                        }
                }
                .padding(.vertical, 7)
            }
        }
    }
}
