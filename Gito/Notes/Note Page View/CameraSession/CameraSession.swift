//
//  CameraSession.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import Foundation
import AVFoundation
import SwiftUI

@Observable
public class CameraSession: NSObject {
    var isRunning = false
    var capturedImageData: Data?

    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.gito.camera.sessionQueue")

    public override init() {
        super.init()
        checkPermissionsAndSetup()
    }

    private func checkPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupSession()
                }
            }
        default:
            break
        }
    }

    private func setupSession() {
        sessionQueue.async {
            self.session.beginConfiguration()

            // Configure input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  self.session.canAddInput(videoDeviceInput) else {
                return
            }
            self.session.addInput(videoDeviceInput)

            // Configure output
            guard self.session.canAddOutput(self.photoOutput) else { return }
            self.session.addOutput(self.photoOutput)

            self.session.commitConfiguration()
        }
    }

    public func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isRunning = true
                }
            }
        }
    }

    public func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isRunning = false
                }
            }
        }
    }

    public func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraSession: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        if let imageData = photo.fileDataRepresentation() {
            DispatchQueue.main.async {
                self.capturedImageData = imageData
                self.stopSession()
            }
        }
    }
}

// MARK: - Camera Preview UI Component
// MARK: - Dedicated Preview UIView to handle layout updates
class VideoPreviewUIView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

// MARK: - Updated Camera Preview UI Component (iOS 17+ Compliant)
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> VideoPreviewUIView {
        let view = VideoPreviewUIView()
        view.backgroundColor = .black

        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
        DispatchQueue.main.async {
            uiView.videoPreviewLayer.frame = uiView.bounds
            
            if let connection = uiView.videoPreviewLayer.connection {
                if connection.isVideoRotationAngleSupported(90.0) {
                    connection.videoRotationAngle = 90.0
                }
            }
        }
    }
}
