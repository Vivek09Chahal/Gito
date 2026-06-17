//
//  OnboardView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/12/26.
//

import SwiftUI

struct OnboardView: View {

    let onBoardPage: [OnboardModel] = [
        OnboardModel(heading: "Learn Anytime, \nEasily Anywhere",
                     image: "onboardImg1",
                     bottomText: "Get Started",
                     bottomTextImg: "arrow.forward.circle.dotted",
                     color: Color.onboardBG1),

        OnboardModel(heading: "Note, When \nyou wish \n or remrember",
                     image: "onboardImg2",
                     bottomText: "Ready to take note",
                     bottomTextImg: "arrow.forward.circle.dotted",
                     color: Color.onboardBG2),
    ]

    @State private var currentPage = 0
    var onFinished: () -> Void

    var body: some View {
        GeometryReader { outerProxy in
            ZStack(alignment: .bottom) {
                TabView(selection: $currentPage) {
                    ForEach(Array(onBoardPage.enumerated()), id: \.offset) { index, page in
                        OnboardPageView(page: page, onBoardPageCount: onBoardPage.count, onFinished: onFinished, currentPage: $currentPage)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                HStack(spacing: 8) {
                    ForEach(0..<onBoardPage.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.black : Color.black.opacity(0.3))
                            .frame(width: currentPage == index ? 12 : 7, height: 7)
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                .padding(.bottom, outerProxy.size.height / 9)
            }
        }
    }
}




