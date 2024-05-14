//
//  ImageItemExtensions.swift
//  ThisPlay
//
import SwiftUI
import DitheringEngine

extension ImageItem {
    
    func downscaleAndDither(_ inputImage: UIImage) -> UIImage? {
        print("Downscaling image to 600 x 448")
        let newSize = CGSize(width: 600, height: 448)
        UIGraphicsBeginImageContextWithOptions(newSize, true, inputImage.scale)
        inputImage.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Error: Failed to create resized image")
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage.cgImage else {
            print("Error: Resized image has no CGImage data")
            return nil
        }

        guard let ditheredCGImage = performDither(inputCGImage: cgImage) else {
            print("Error: Failed to dither the image")
            return nil
        }

        let ditheredUIImage = UIImage(cgImage: ditheredCGImage)
        return ditheredUIImage
    }
    
    func performDither(inputCGImage: CGImage) -> CGImage? {
        let ditheringEngine = DitheringEngine()
        do {
            try ditheringEngine.set(image: inputCGImage)
            print("Starting dithering process")
            let ditheredCGImage = try ditheringEngine.dither(
                usingMethod: .floydSteinberg,
                andPalette: .custom,
                withDitherMethodSettings: EmptyPaletteSettingsConfiguration(),
                withPaletteSettings: CustomPaletteSettingsConfiguration(palette: EPDColors.palette)
            )
            print("Dithering process completed successfully")
            return ditheredCGImage
        } catch {
            print("Error while performing dithering: \(error)")
            return nil
        }
    }
}
