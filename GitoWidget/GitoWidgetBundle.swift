//
//  GitoWidgetBundle.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 03/07/26.
//

import WidgetKit
import SwiftUI

@main
struct GitoWidgetBundle: WidgetBundle {
    var body: some Widget {
        GitoWidget()
        GitoWidgetControl()
//        GitoWidgetLiveActivity()
    }
}
