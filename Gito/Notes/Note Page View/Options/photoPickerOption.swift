//
//  photoPickerOption.swift
//  Gito
//
//  Created by Vivek Chahal on 6/16/26.
//

import SwiftUI
import PhotosUI
import Foundation

@Observable
class photoPicker {

    enum ImageState: Equatable {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)

        static func == (lhs: ImageState, rhs: ImageState) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty): return true
            case (.loading, .loading): return true
            case (.success, .success): return true
            case (.failure, .failure): return true
            default: return false
            }
        }
    }

    enum TransferError: Error {
        case importFailed
    }

    struct importImage: Transferable {
        let image: Image

        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
            #if canImport(AppKit)
                guard let nsImage = NSImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(nsImage: nsImage)
                return ProfileImage(image: image)
            #elseif canImport(UIKit)
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return importImage(image: image)
            #else
                throw TransferError.importFailed
            #endif
            }
        }
    }

    var imageState: ImageState = .empty

    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }


    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: importImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
}
