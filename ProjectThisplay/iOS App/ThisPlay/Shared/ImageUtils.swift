//
//  ImageUtils.swift
//  ThisPlay
//
import Foundation
import UIKit
import SwiftUI
import CoreImage

class ImageUtils {
    // Function to get UIColor components from asset catalog using color name
    static func getColorComponents(_ name: String) -> [UInt8]? {
        guard let color = UIColor(named: name),
                let components = color.cgColor.components,
                components.count >= 3 else {
            print("Failed to load color: \(name)")
            return nil
        }
        return components.map { UInt8($0 * 255) }
    }

    // Find the closest palette color
    static func findClosestPaletteColor(r: UInt8, g: UInt8, b: UInt8) -> String {
        var lowestColor: String?
        var lowestDistance: Float = 1000
        for (color, components) in EPDColors.paletteColors {
            let distance = sqrt(pow(Float(r) - Float(components[0]), 2) +
                                pow(Float(g) - Float(components[1]), 2) +
                                pow(Float(b) - Float(components[2]), 2))
            if distance < lowestDistance {
                lowestColor = color
                lowestDistance = distance
            }
        }
        return lowestColor ?? "Blank"
    }
    
    // Extract HMSB from canvas
    static func extractHMSBFromCanvas(image: UIImage) -> [String] {
        guard let cgImage = image.cgImage else {
            print("Failed to get CGImage from UIImage")
            return []
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            print("Failed to get sRGB color space")
            return []
        }
        
        var rawData = [UInt8](repeating: 0, count: totalBytes)
        guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            print("Failed to create CGContext")
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let NUM_BLOCKS = 8
        var bands = [[UInt8]](repeating: [UInt8](repeating: 0, count: width * height / (2 * NUM_BLOCKS)), count: NUM_BLOCKS)
            
        let bandHeight = height / NUM_BLOCKS
        var bufferIndex = 0
        
        for y in 0..<height {
            let bandNumber = y / bandHeight
            var bandIndex = (width / 2) * (y % bandHeight)
            for _ in stride(from: 0, to: width, by: 2) {
                let red1 = rawData[bufferIndex]
                let green1 = rawData[bufferIndex + 1]
                let blue1 = rawData[bufferIndex + 2]
                bufferIndex += 4
                let color1 = findClosestPaletteColor(r: red1, g: green1, b: blue1)
                
                let red2 = rawData[bufferIndex]
                let green2 = rawData[bufferIndex + 1]
                let blue2 = rawData[bufferIndex + 2]
                bufferIndex += 4
                let color2 = findClosestPaletteColor(r: red2, g: green2, b: blue2)
                
                let colorCode1 = EPDColors.colorCodes[color1] ?? 0x07
                let colorCode2 = EPDColors.colorCodes[color2] ?? 0x07
                
                bands[bandNumber][bandIndex] = (colorCode1 << 4) | colorCode2
                bandIndex += 1
            }
        }
        
        let base64Bands = bands.map { Data($0).base64EncodedString() }
        //print("Base64 Bands: \(base64Bands)")
        return base64Bands
    }
    
    static func distinctColors(image: UIImage) -> [UIColor] {
        // we need to use corgraphics for this, so make sure we have valid cgImage data in our UIImage first
        guard let cgImage = image.cgImage else { return [] }
        // grab the pixel count for both width and height
        let width = cgImage.width
        let height = cgImage.height
        
        guard let data = cgImage.dataProvider?.data else { return [] }
        let pixelData = CFDataGetBytePtr(data)
        // now create a set to collect our distinct colors in
        var colorSet = Set<UIColor>()
        // and start iterating through the pixels in the image by column (x) then row(y)
        colLoop: for x in 0..<width {
            rowLoop: for y in 0..<height {
                let pixelInfo = ((width * y) + x) * 4
                
                let r = CGFloat(pixelData![pixelInfo]) / 255.0
                let g = CGFloat(pixelData![pixelInfo + 1]) / 255.0
                let b = CGFloat(pixelData![pixelInfo + 2]) / 255.0
                let a = CGFloat(pixelData![pixelInfo + 3]) / 255.0
                
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                colorSet.insert(color)
                if colorSet.count > 10 {
                    // we know our palette only has 8 colors, so just to be safe
                    // but to be safe, we'll wait until we have a couple more distinct
                    // colors in our set than should be possible for a compatible image
                    // then break the outer loop to save on CPU and time
                    break colLoop
                }
            }
        }
        // return an array from our color set
        return Array(colorSet)
    }
    
    // Check if the image is already the correct size
    static func sizeCompatible(_ image: UIImage) -> Bool {
        return image.size.width == 600 && image.size.height == 448
    }

    // Check if the image is already compatible with the e-paper display
    static func paletteCompatible(_ inputImage: UIImage) -> Bool {
        let imageColors = distinctColors(image: inputImage)
        let colorInfos: [String] = imageColors.compactMap { color in
            return color.toHex()
        }
        colorInfos.forEach { c in
            print("colorInfo: \(c)")
        }
        for hexValue in colorInfos {
            if !EPDColors.colorNames.contains(where: { EPDColors.hexValue(for: $0) == hexValue }) {
                return false
            }
        }
        return true
    }
}
