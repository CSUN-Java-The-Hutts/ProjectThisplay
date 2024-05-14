//
//  TextItemExtensions.swift
//  ThisPlay
//
import Foundation
import SwiftUI
import SwiftData
import Combine

extension TextItem {
    // Move methods from ViewModel to here
    func renderTextToImage(scale: CGFloat = 1.0) -> UIImage? {
        // these values are hard coded based on the WaveShare 5.65" 600x448
        // 7-color acep e-paper display
        // in the future these should be refactored into a model class
        // to add support for multiple types and sizes of displays
        let baseFontSizePixels: CGFloat = 16.6
        let ppi: CGFloat = 132.5
        
        var baseFontSizePoints: CGFloat {
            baseFontSizePixels / (ppi / 72)
        }
        
        var currentFontSizePixels: CGFloat {
            baseFontSizePixels * scaleFactor
        }
        let imageWidth: CGFloat = 600
        let imageHeight: CGFloat = imageWidth / 1.34
        let scaleFactorAdjustment = imageWidth / UIScreen.main.bounds.width

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: imageWidth, height: imageHeight), format: format)
        let image = renderer.image { context in
            UIColor(named: backgroundColor)?.setFill() ?? UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment(textAlignmentForMultiline)

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: baseFontSizePoints * scaleFactor * scaleFactorAdjustment),
                .foregroundColor: UIColor(named: textColor) ?? UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let string = NSAttributedString(string: text, attributes: attrs)
            
            // Calculate the bounding rect for the text
            let textSize = string.boundingRect(
                with: CGSize(width: imageWidth, height: imageHeight),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size
            
            var textRect = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
            
            // Adjust the rect based on alignment
            switch horizontalAlignment {
            case .leading:
                textRect.origin.x = 0
            case .center:
                textRect.origin.x = (imageWidth - textSize.width) / 2
            case .trailing:
                textRect.origin.x = imageWidth - textSize.width
            }
            
            switch verticalAlignment {
            case .top:
                textRect.origin.y = 0
            case .center:
                textRect.origin.y = (imageHeight - textSize.height) / 2
            case .bottom:
                textRect.origin.y = imageHeight - textSize.height
            }
            
            string.draw(in: textRect)
        }
        
        return image
    }
}
