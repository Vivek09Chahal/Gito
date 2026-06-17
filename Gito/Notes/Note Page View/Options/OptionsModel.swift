//
//  OptionsModel.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import Foundation

enum NoteOptionActions: String, CaseIterable, Identifiable {

    case addImage = "Add Image"
    case takePhoto = "Take Photo"
    case draw = "draw"

    var id: String { rawValue }

    var icons: String {
        switch self {
        case .addImage: return "photo.fill.on.rectangle.fill"
        case .takePhoto: return "camera"
        case .draw: return "pencil.and.outline"
        }
    }
}
