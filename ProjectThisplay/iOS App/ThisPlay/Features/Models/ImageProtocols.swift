//
//  ImageProtocols.swift
//  ThisPlay
//
import SwiftUI
import UniformTypeIdentifiers

protocol ImageProcessing {
    var processedImageData: Data? { get set }
    var processedImage: Image? { get }
    func getProcessedUIImage() -> UIImage?
}

extension ImageProcessing {
    // simple wrapper to convert a UIImage to SwiftUi Image()
    var processedImage: Image? {
        guard let uiImage = getProcessedUIImage() else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

struct ImageTransferable: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) { transferable in
            guard let imageData = transferable.image.pngData() else {
                throw TransferError.dataConversionFailed
            }
            return imageData
        }
    }
}

enum TransferError: Error {
    case dataConversionFailed
}
