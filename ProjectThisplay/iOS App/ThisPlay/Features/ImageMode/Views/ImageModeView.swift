//
//  ImageModeView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData
import PhotosUI
import Mantis

struct ImageModeView: View {
    @Bindable var appSettings: AppSettings
    @Bindable var imageItem: ImageItem
    @State private var showCropView = false
    @State private var isProcessing = false // State to handle visibility of the progress overlay
    @State private var showProcessedImage = false
    @State private var photosPickerItem: PhotosPickerItem?

    var body: some View {
        VStack {
            if imageItem.inputImageData == nil && imageItem.processedImageData == nil {
                // we're in 'create a new image' mode, so show the placeholder
                // Placeholder image
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                PhotosPicker("Select an image", selection: $photosPickerItem, matching: .images)
                    .onChange(of: photosPickerItem) {
                        Task {
                            if let data = try? await photosPickerItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                imageItem.inputImageData = uiImage.pngData()
                                showCropView = true
                            } else {
                                print("Error loading image")
                            }
                        }
                    }
            } else {
                // we now have at least a valid input iamge
                if showProcessedImage, let processedImage = imageItem.processedImage {
                    processedImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if let inputImage = imageItem.inputImage {
                    inputImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Picker("Image View", selection: $showProcessedImage) {
                    Text("Processed").tag(true)
                    Text("Original").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                Button("Re-crop Image") {
                    showCropView = true
                }
                .padding()
            }
        }
        .sheet(isPresented: $showCropView) {
            if let inputImage = imageItem.inputUIImage {
                ImageCropperView(image: inputImage) { croppedImage in
                    isProcessing = true // Start showing progress indicator
                    Task {
                        await imageItem.setProcessedImage(croppedImage: croppedImage)
                        isProcessing = false // Hide progress indicator
                        showProcessedImage = true // Automatically switch to show the processed image
                    }
                }
            }
        }
        .progressOverlay(isShowing: $isProcessing)
        .conditionalShareButton(imageProcessor: imageItem)
    }
}

// Progress Overlay View
struct ProgressOverlay: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                ProgressView("Processing...")
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5, anchor: .center)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.45))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

extension View {
    func progressOverlay(isShowing: Binding<Bool>) -> some View {
        overlay(ProgressOverlay(isShowing: isShowing))
    }
}


struct ImageCropperView: UIViewControllerRepresentable {
    var image: UIImage
    var onCrop: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CropViewController {
        let cropViewController = Mantis.cropViewController(image: image)
        cropViewController.delegate = context.coordinator
        cropViewController.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 600.0 / 448.0)
        cropViewController.config.cropShapeType = .rect
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: CropViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: ImageCropperView

        init(_ parent: ImageCropperView) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            cropViewController.dismiss(animated: true)
            parent.onCrop(cropped)
        }

        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
            cropViewController.dismiss(animated: true)
            // Handle the failure case, e.g., show an alert to the user
            print("Failed to crop the image")
        }

        func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {
            // Optional: Handle the beginning of a resize action
            print("Crop resize began")
        }

        func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {
            // Optional: Handle the end of a resize action
            print("Crop resize ended")
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            cropViewController.dismiss(animated: true)
        }
    }
}
