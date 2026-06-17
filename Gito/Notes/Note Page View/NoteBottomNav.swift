//
//  BottomNav.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct BottomNav: View {

    var proxy: GeometryProxy
    @Binding var presentOptionSheet: Bool
    @Binding var presentColorSheet: Bool
    @Binding var presentMenuSheet: Bool
    var lastEdited: Date?

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "plus.app")
                .resizable()
                .frame(width: proxy.size.width / 19, height: proxy.size.width / 19)
                .onTapGesture {
                    presentOptionSheet.toggle()
                }

            Image(systemName: "paintpalette")
                .resizable()
                .frame(width: proxy.size.width / 19, height: proxy.size.width / 19)
                .onTapGesture {
                    presentColorSheet.toggle()
                }

            Spacer()

            if let lastEdited {
                Text("Edit on \(lastEdited.formatted(.dateTime.day().month(.abbreviated).hour().minute()))")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer()

            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .padding(20)
                .frame(width: proxy.size.width / 15, height: proxy.size.width / 15)
                .onTapGesture {
                    presentMenuSheet.toggle()
                }

        }
        .padding()
    }
}

#Preview {
    GeometryReader { geometry in
        VStack {
            Spacer()
            BottomNav(
                proxy: geometry,
                presentOptionSheet: .constant(false),
                presentColorSheet: .constant(false),
                presentMenuSheet: .constant(false),
                lastEdited: Date()
            )
        }
    }
}

