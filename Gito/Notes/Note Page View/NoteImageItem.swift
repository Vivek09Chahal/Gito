//
//  NoteImageItem.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import Foundation

enum NoteImageType: Codable {
    case photo
    case drawing
}

struct NoteImageItem: Codable, Equatable {
    var jpegData: Data
    var rawDrawingData: Data?
    var type: NoteImageType
}
