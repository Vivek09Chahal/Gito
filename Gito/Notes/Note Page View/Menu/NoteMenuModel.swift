//
//  MenuModel.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//

import Foundation

enum NoteMenuAction: String, CaseIterable, Identifiable {
    case delete = "Delete"
    case send = "Send"
    case copy = "Copy"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .delete: return "trash"
        case .send: return "square.and.arrow.up"
        case .copy: return "doc.on.doc"
        }
    }

    var isDestructive: Bool { self == .delete }
}
