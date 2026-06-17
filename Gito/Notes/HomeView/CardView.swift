//
//  CardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/13/26.
//

import SwiftUI

struct CardView: View {

    let color: Color
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(color)
                .frame(width: CGFloat(width), height: CGFloat(height))
        }
    }
}
