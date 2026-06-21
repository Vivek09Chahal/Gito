//
//  OnboardModel.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import SwiftUI

struct OnboardModel: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var symbolName: String          // SF Symbol fallback if no custom image exists
    var imageName: String? = nil    // Optional illustration from Assets.xcassets
    var accentColor: Color
    var tag: String
    var floatingSymbols: [String] = []   // small decorative SF Symbols around the illustration
}
