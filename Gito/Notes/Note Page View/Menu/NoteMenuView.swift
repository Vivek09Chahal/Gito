//
//  NoteMenuView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI


struct NoteMenuView: View {

    var action: (NoteMenuAction) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(NoteMenuAction.allCases) { item in
                Button {
                    action(item)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundStyle(item.isDestructive ? .red : .primary)
                        Text(item.rawValue)
                            .foregroundStyle(item.isDestructive ? .red : .primary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}
