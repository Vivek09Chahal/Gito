//
//  GitoWidgetBundle.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 25/06/26.
//

import WidgetKit
import SwiftUI

@main
struct GitoWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NotesListWidget()
        SingleNoteWidget()
    }
}
