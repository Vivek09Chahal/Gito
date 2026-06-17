//
//  OnboardPageView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/15/26.
//


import SwiftUI

struct OnboardPageView: View {

    var page: OnboardModel
    var onBoardPageCount: Int
    var onFinished: () -> Void
    @Binding var currentPage: Int

    var body: some View {
        ZStack(alignment: .top) {
            page.color
                .ignoresSafeArea()

            GeometryReader { proxy in
                VStack(alignment: .leading) {
                    VStack {
                        Text(page.heading)
                            .foregroundStyle(.primary)
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)

                        Spacer()

                        Image(page.image)

                        Spacer()

                        RoundedRectangle(cornerRadius: 30)
                            .foregroundStyle(.black)
                            .padding()
                            .frame(height: proxy.size.height / 8.3)
                            .overlay(alignment: .leading) {
                                HStack {
                                    Text(page.bottomText)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                        .padding(.leading, 35)

                                    Spacer()

                                    Button(action: {
                                        if currentPage < onBoardPageCount - 1 {
                                            withAnimation(.snappy) {
                                                currentPage += 1
                                            }
                                        } else {
                                            onFinished()
                                        }
                                    }) {
                                        Image(systemName: page.bottomTextImg)
                                            .resizable()
                                            .frame(width: proxy.size.height / 25, height: proxy.size.height / 25)
                                            .foregroundStyle(.white)
                                            .padding(.trailing, 30)
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}
