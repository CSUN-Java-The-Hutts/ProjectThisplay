//
//  TextItem.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

@Model
class TextItem: HistoryItem, ImageProcessing {
    var text: String
    var scaleFactor: CGFloat
    var lastEditDate: Date
    var horizontalAlignment: HorizontalOption
    var verticalAlignment: VerticalOption
    var textColor: String
    var backgroundColor: String
    var server: Server?
    @Attribute(.externalStorage) var processedImageData: Data?

    init(text: String,
         scaleFactor: CGFloat,
         horizontalAlignment: HorizontalOption,
         verticalAlignment: VerticalOption,
         textColor: String = EPDColors.black,
         backgroundColor: String = EPDColors.white,
         lastEditDate: Date = Date()) {
        
        self.text = text
        self.scaleFactor = scaleFactor
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.lastEditDate = lastEditDate
    }
    
    // Convenience initializer with default values
    convenience init() {
        self.init(text: "", scaleFactor: 1.0, horizontalAlignment: .center, verticalAlignment: .center)
    }
    
    var textAlignment: Alignment {
        Alignment(horizontal: horizontalAlignment.alignment, vertical: verticalAlignment.alignment)
    }
    
    var textAlignmentForMultiline: TextAlignment {
        switch horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
    
    func getProcessedUIImage() -> UIImage? {
        guard let uiImage = renderTextToImage(scale: 1.0) else {
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
