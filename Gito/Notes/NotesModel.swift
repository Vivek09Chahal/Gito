//
//  NotesModel.swift
//  Gito
//
//  Created by Vivek Chahal on 6/13/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class NotesModel {
    var id: UUID
    var bgImage: bgImage?
    var noteTitle: String
    var noteContent: String
    var noteTypeCase: noteTypes
    var isImportant: Bool
    var contentSize: CGFloat
    var notePageColor: pageColors
    var lastEdited: Date
    var imageItems: [NoteImageItem]

    init(id: UUID = .init(),
         bgImage: bgImage? = nil, noteTitle: String, noteTypeCase: noteTypes,
         noteContent: String, isImportant: Bool, notePageColor: pageColors,
         contentSize: CGFloat, lastEdited: Date = Date.now, imageItems: [NoteImageItem] = []) {
        self.id = id
        self.bgImage = bgImage
        self.noteTitle = noteTitle
        self.noteTypeCase = noteTypeCase
        self.noteContent = noteContent
        self.isImportant = isImportant
        self.notePageColor = notePageColor
        self.contentSize = contentSize
        self.lastEdited = lastEdited
        self.imageItems = imageItems
    }
}

// Note Type
enum noteTypes: String, Codable {
    case today
    case plans
    case task
    case note
    case remember
}

// Page Color
enum pageColors: String, Codable, CaseIterable, Hashable {
    case defaultColor
    case coral
    case lemonYellow
    case sage
    case lemonGreen
    case cedarBark
    case rustWood
    case evergreenMoss
}

extension pageColors {
    var pageColor: Color {
        switch self {
        case .defaultColor: return .default
        case .coral: return .coral
        case .lemonYellow: return .lemonYellow
        case .sage: return .sage
        case .lemonGreen: return .lemonGreen
        case .cedarBark: return .cedarBark
        case .rustWood: return .rustWood
        case .evergreenMoss: return .evergreenMoss
        }
    }
}

// Background images
enum bgImage: String, Codable, CaseIterable, Hashable {
    case image1
    case image2
    case image3
    case image4
    case image5
    case image6
    case image7
    case image8
}

extension bgImage {
    var imageName: String {
        switch self {
        case .image1: "bg1"
        case .image2: "bg2"
        case .image3: "bg3"
        case .image4: "bg4"
        case .image5: "bg5"
        case .image6: "bg6"
        case .image7: "bg7"
        case .image8: "bg8"
        }
    }
}

enum NoteImageType: Codable {
    case photo
    case drawing
}

struct NoteImageItem: Codable, Equatable {
    var id = UUID()
    var jpegData: Data
    var rawDrawingData: Data?
    var type: NoteImageType
}

struct DrawingEditTarget: Identifiable {
    let id = UUID()
    let index: Int
}
