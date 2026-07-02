//
//  GitoWidgetBundle.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 25/06/26.
//

import WidgetKit
import SwiftUI

@main
struct GitoWidgetBundle: WidgetBundle {
    var body: some Widget {
        GitoWidget()
        GitoWidgetControl()
        GitoWidgetLiveActivity()
    }
}
