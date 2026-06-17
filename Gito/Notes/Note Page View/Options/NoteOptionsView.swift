//
//  NoteOptionsView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct NoteOptionsView: View {

    var action: (NoteOptionActions) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {

            ForEach(NoteOptionActions.allCases) { item in
                Button {
                    action(item)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: item.icons)
                            .foregroundStyle(.white)
                        
                        Text(item.rawValue)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .toolbarBackground(Color.black, for: .bottomBar)
    }
}
