//
//  GitoWidgetLiveActivity.swift
//  GitoWidget
//
//  Created by Vivek Chahal on 25/06/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GitoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GitoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GitoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GitoWidgetAttributes {
    fileprivate static var preview: GitoWidgetAttributes {
        GitoWidgetAttributes(name: "World")
    }
}

extension GitoWidgetAttributes.ContentState {
    fileprivate static var smiley: GitoWidgetAttributes.ContentState {
        GitoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GitoWidgetAttributes.ContentState {
         GitoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GitoWidgetAttributes.preview) {
   GitoWidgetLiveActivity()
} contentStates: {
    GitoWidgetAttributes.ContentState.smiley
    GitoWidgetAttributes.ContentState.starEyes
}
