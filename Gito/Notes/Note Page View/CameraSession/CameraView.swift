//
//  CameraView.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI

struct CustomCameraView: View {

    @State var cameraSession = CameraSession()
    var onPhotoCaptured: (Data) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraSession.session)
                .ignoresSafeArea()

            // Camera HUD Controls
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                // Shutter Button
                Button(action: { cameraSession.capturePhoto() }) {
                    Circle()
                        .fill(.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 70, height: 70)
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .foregroundColor(.white)
        .onAppear {
            cameraSession.startSession()
        }
        .onDisappear {
            cameraSession.stopSession()
        }
        .onChange(of: cameraSession.capturedImageData) { _, newData in
            if let data = newData {
                onPhotoCaptured(data)
                dismiss()
            }
        }
    }
}
