//
//  SharedModels.swift
//  GitoWidget
//
//  Mirror of Gito/NotesModel.swift compiled into the GitoWidgetExtension target.
//  The main app target cannot export types to a widget extension, so we re-declare
//  all types the widget needs here.
//
//  ⚠️  Keep this file in sync with Gito/NotesModel.swift whenever the schema changes.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - NotesModel

@Model
final class NotesModel {
    var id: UUID
    var bgImage: bgImage?
    var noteTitle: String
    var noteContent: String
    var isImportant: Bool
    var contentSize: CGFloat
    var notePageColor: pageColors
    var lastEdited: Date
    var imageItems: [NoteImageItem]
    var drawingItems: [NoteDrawingItem]

    init(id: UUID = .init(),
         bgImage: bgImage? = nil,
         noteTitle: String,
         noteContent: String,
         isImportant: Bool,
         notePageColor: pageColors,
         contentSize: CGFloat,
         lastEdited: Date = Date.now,
         imageItems: [NoteImageItem] = [],
         drawingItems: [NoteDrawingItem] = []) {
        self.id = id
        self.bgImage = bgImage
        self.noteTitle = noteTitle
        self.noteContent = noteContent
        self.isImportant = isImportant
        self.notePageColor = notePageColor
        self.contentSize = contentSize
        self.lastEdited = lastEdited
        self.imageItems = imageItems
        self.drawingItems = drawingItems
    }
}

// MARK: - Page Colors

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
    /// Inline color values matching the main app's CardColor asset catalog.
    /// Using literals here avoids a dependency on the widget's own asset catalog.
    var pageColor: Color {
        switch self {
        case .defaultColor:   return Color(red: 0.18, green: 0.18, blue: 0.20)   // dark neutral
        case .coral:          return Color(red: 0.91, green: 0.44, blue: 0.37)   // coral
        case .lemonYellow:    return Color(red: 0.98, green: 0.89, blue: 0.36)   // lemon yellow
        case .sage:           return Color(red: 0.53, green: 0.66, blue: 0.53)   // sage green
        case .lemonGreen:     return Color(red: 0.67, green: 0.84, blue: 0.29)   // lemon green
        case .cedarBark:      return Color(red: 0.49, green: 0.30, blue: 0.20)   // cedar bark
        case .rustWood:       return Color(red: 0.72, green: 0.37, blue: 0.20)   // rust wood
        case .evergreenMoss:  return Color(red: 0.20, green: 0.35, blue: 0.25)   // evergreen moss
        }
    }
}

// MARK: - Background Images

enum bgImage: String, Codable, CaseIterable, Hashable {
    case image1, image2, image3, image4
    case image5, image6, image7, image8
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

// MARK: - Image / Drawing Item Types

enum NoteImageType: Codable {
    case photo
    case drawing
}

struct NoteImageItem: Codable, Equatable {
    var id: UUID
    var jpegData: Data
    var rawDrawingData: Data?
    var type: NoteImageType

    init(id: UUID = UUID(), jpegData: Data, rawDrawingData: Data? = nil, type: NoteImageType) {
        self.id = id
        self.jpegData = jpegData
        self.rawDrawingData = rawDrawingData
        self.type = type
    }
}

struct NoteDrawingItem: Codable, Equatable, Identifiable {
    var id = UUID()
    var rawDrawingData: Data
}
