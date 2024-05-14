//
//  View+Share.swift
//  ThisPlay
//
import SwiftUI

struct ShareButtonModifier<T: ImageProcessing>: ViewModifier {
    var imageProcessor: T
    @State private var showUploadImageView = false
    @State private var uploadImage: UIImage? = nil

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if let image = imageProcessor.processedImage {
                            ShareLink(item: image, preview: SharePreview("Processed Image: ", image: image)) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } else {
                            Text("Processed Image Error")
                        }
                        Button(action: saveToPhotoLibrary) {
                            Label("Save to Photo Library", systemImage: "photo")
                        }
                        Button(action: sendToServer) {
                            Label("Send to Server", systemImage: "wifi")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showUploadImageView) {
                if let image = imageProcessor.getProcessedUIImage() {
                    UploadImageView(image: image, isPresented: $showUploadImageView)
                }
            }
    }

    private func saveToPhotoLibrary() {
        if let image = imageProcessor.getProcessedUIImage() {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: image)
        }
    }

    private func sendToServer() {
        if let image = imageProcessor.getProcessedUIImage() {
            uploadImage = image
            DispatchQueue.main.async {
                showUploadImageView = true
            }
        }
    }
}

extension View {
    func shareButton<T: ImageProcessing>(imageProcessor: T) -> some View {
        self.modifier(ShareButtonModifier(imageProcessor: imageProcessor))
    }

    func conditionalShareButton<T: ImageProcessing>(imageProcessor: T) -> some View {
        Group {
            if imageProcessor.processedImageData != nil {
                self.modifier(ShareButtonModifier(imageProcessor: imageProcessor))
            } else {
                self
            }
        }
    }
}
