//
//  ImageItem.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

@Model
class ImageItem: HistoryItem, ImageProcessing {
    var lastEditDate: Date
    var server: Server?
    @Attribute(.externalStorage) var inputImageData: Data?
    @Attribute(.externalStorage) var processedImageData: Data?
    // computed properties for the Image and UIImage objects
    var inputUIImage: UIImage? {
        getInputUIImage()
    }
    var inputImage: Image? {
        getInputImage()
    }

    init(lastEditDate: Date = Date()) {
        self.lastEditDate = lastEditDate
        self.inputImageData = nil
        self.processedImageData = nil
    }
    
    // method to process the image, then save the newly processed image as png data
    func setProcessedImage(croppedImage: UIImage) async {
        guard let processedUIImage = downscaleAndDither(croppedImage) else {
            print("Error: Could not downscale and dither cropped image")
            return
        }
        processedImageData = processedUIImage.pngData()
    }
    
    // get the processed UIImage from the previously saved png data
    func getProcessedUIImage() -> UIImage? {
        guard let data = processedImageData else {
            print("Error: processedImageData is missing")
            return nil
        }
        guard let processedUIImage = UIImage(data: data) else {
            print("Error: Could not convert processedImageData to UIImage")
            return nil
        }
        return processedUIImage
    }
    
    // get the original/input image, as UIKit UIImage()
    private func getInputUIImage() -> UIImage? {
        guard let data = inputImageData else {
            print("Error: inputImageData is missing")
            return nil
        }
        guard let inputUIImage = UIImage(data: data) else {
            print("Error: Could not convert inputImageData to UIImage")
            return nil
        }
        return inputUIImage
    }
    
    // get the original/input image, as SwiftUI Image()
    private func getInputImage() -> Image? {
        guard let uiImage = getInputUIImage() else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
