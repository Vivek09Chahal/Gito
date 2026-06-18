//
//  EmptyStateView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct EmptyStateView: View {

    var body: some View {
        VStack(spacing: 18) {
            Image("emptyState")
                .font(.system(size: 60, weight: .thin))

            Text("Notes you add appear here")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    EmptyStateView()
        .preferredColorScheme(.dark)
}
