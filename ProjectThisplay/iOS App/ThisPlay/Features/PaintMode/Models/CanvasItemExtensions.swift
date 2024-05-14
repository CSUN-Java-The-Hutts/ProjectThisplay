//
//  CanvasItemExtensions.swift
//  ThisPlay
//
import SwiftUI
import SwiftData
import UIKit

extension CanvasItem {
    func createCanvasImage(size: CGSize, scale: CGFloat) -> UIImage? {
        print("Target image sizes: Width = \(size.width), Height = \(size.height)")
        let originalCanvasSize = CGSize(width: canvasWidth, height: canvasHeight)
        let scaleX = size.width / originalCanvasSize.width
        let scaleY = size.height / originalCanvasSize.height
        print("Computed scales: Width = \(scaleX), Height = \(scaleY)")

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Failed to create graphics context")
            return nil
        }

        context.setFillColor(Color(backgroundColor).safeCGColor)
        context.fill(CGRect(origin: .zero, size: size))
        print("Background filled with color: \(backgroundColor)")

        // Scale and draw paths
        for (index, path) in paths.enumerated() {
            let cgPath = CGMutablePath()
            if let firstPoint = path.points.first {
                cgPath.move(to: CGPoint(x: firstPoint.x * scaleX, y: firstPoint.y * scaleY))
                for point in path.points.dropFirst() {
                    cgPath.addLine(to: CGPoint(x: point.x * scaleX, y: point.y * scaleY))
                }
            }

            context.addPath(cgPath)
            context.setStrokeColor(Color(path.colorName).safeCGColor)
            context.setLineWidth(path.lineWidth * scaleX) // Adjust line width based on scale
            context.strokePath()
            print("Drew path \(index) with color \(path.colorName) and line width \(path.lineWidth)")
        }

        // Scale and draw shapes
        for (index, shape) in shapes.enumerated() {
            let transformedRect = shape.rect.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
            context.setFillColor(Color(shape.colorName).safeCGColor)
            context.setStrokeColor(Color(shape.colorName).safeCGColor)
            context.setLineWidth(shape.lineWidth * scaleX)

            switch shape.type {
            case .circle:
                context.strokeEllipse(in: transformedRect)
                if shape.isFilled {
                    context.fillEllipse(in: transformedRect)
                }
            case .rectangle:
                context.stroke(transformedRect)  // Always stroke the shape
                if shape.isFilled {
                    context.fill(transformedRect)  // Fill the shape if it's meant to be filled
                }
            }
            
            print("Drew \(shape.type) \(index) with dimensions \(transformedRect) and color \(shape.colorName), filled: \(shape.isFilled)")
        }

        // Scale and draw text entries
        for (index, entry) in textEntries.enumerated() {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: entry.fontSize * scaleX), // Scale font size
                .foregroundColor: UIColor(Color(entry.colorName))
            ]
            let string = NSAttributedString(string: entry.text, attributes: attributes)
            let textSize = string.size()
            let scaledPosition = CGPoint(
                x: entry.position.x * scaleX - (textSize.width / 2), // Center horizontally
                y: entry.position.y * scaleY - (textSize.height / 2) // Center vertically
            )
            string.draw(at: scaledPosition)
            print("Text \(index): Original position = \(entry.position), Scaled position = \(scaledPosition), Text size = \(textSize)")
            print("Drew text \(index) at position \(scaledPosition) with text \(entry.text)")
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            print("Failed to get image from context")
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}
