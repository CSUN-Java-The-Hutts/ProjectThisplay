//
//  CanvasItem.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

@Model
class CanvasItem: HistoryItem, ImageProcessing {
    var textEntries: [TextEntry]
    var paths: [DrawingPath]
    var shapes: [DrawingShape]
    var backgroundColor: String
    var canvasWidth: CGFloat
    var canvasHeight: CGFloat
    var lastEditDate: Date
    var server: Server?
    @Attribute(.externalStorage) var processedImageData: Data?
    
    init(textEntries: [TextEntry] = [],
         paths: [DrawingPath] = [],
         shapes: [DrawingShape] = [],
         backgroundColor: String = EPDColors.white,
         canvasWidth: CGFloat = 600,
         canvasHeight: CGFloat = 448,
         lastEditDate: Date = Date()) {
        
        self.textEntries = textEntries
        self.paths = paths
        self.shapes = shapes
        self.backgroundColor = backgroundColor
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.lastEditDate = lastEditDate
    }
    
    var orderedElements: [DrawableElement] {
        var elements: [DrawableElement] = []
        elements.append(contentsOf: textEntries.map { .text($0) })
        elements.append(contentsOf: paths.map { .path($0) })
        elements.append(contentsOf: shapes.map { .shape($0) })
        return elements.sorted(by: { $0.zIndex < $1.zIndex })
    }
    
    func addWithUniqueZIndex(for newElement: DrawableElement) {
        let zIndices = Set(orderedElements.map { $0.zIndex })
        var newZIndex = newElement.zIndex
        
        while zIndices.contains(newZIndex) {
            newZIndex += 1
        }
        
        switch newElement {
        case .text(var entry):
            entry.zIndex = newZIndex
            textEntries.append(entry)
            print("Added TextEntry: \(entry)")
        case .path(var path):
            path.zIndex = newZIndex
            paths.append(path)
            print("Added DrawingPath: \(path)")
        case .shape(var shape):
            shape.zIndex = newZIndex
            shapes.append(shape)
            print("Added DrawingShape: \(shape)")
        }
    }
    
    // Function to update our values for the actual displayed canvas size
    func updateCanvasSize(width: CGFloat, height: CGFloat) {
        canvasWidth = width
        canvasHeight = height
        //print("Updated Canvas Size: Width = \(width), Height = \(height)")
    }
    
    func getProcessedUIImage() -> UIImage? {
        guard let uiImage = createCanvasImage(size: CGSize(width: 600, height: 448), scale: 1.0) else {
            return nil
        }
        return uiImage
    }
    
    func getProcessedImage() -> Image? {
        guard let uiImage = getProcessedUIImage() else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
