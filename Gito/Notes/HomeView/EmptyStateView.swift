//
//  EmptyStateView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        Color.clear
            .frame(minHeight: 400) // Base safety fallback height
            .background(
                GeometryReader { geometry in
                    VStack(spacing: 12) {
                        Text("Create Notes")
                            .font(.title2)
                            .fontWeight(.medium)

                        Image("emptyState")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width / 2, height: geometry.size.width / 2)
                    }
                    // Positions the inner container perfectly in the center of the available space
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 1.4)
                }
            )
    }
}

#Preview {
    EmptyStateView()
}
