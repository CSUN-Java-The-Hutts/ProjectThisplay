//
//  CanvasView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData
import UIKit

// Enum for our drag gestures, used when drawing
enum DragState {
    case inactive
    case dragging(value: CGPoint)
}

struct PaintModeView: View {
    @Environment(\.modelContext) var modelContext
    @Bindable var appSettings: AppSettings
    @Bindable var canvasItem: CanvasItem
    @State private var showingHistory = false
    @State private var showingSaveSheet = false
    @State private var showingUploadSheet = false
    @State private var selectedColor: String = "black"
    @State private var currentMode: DrawingMode = .freeform
    @State private var strokeWidth: CGFloat = 5.0
    @State private var fontSize: CGFloat = 14.0
    @State private var userText: String = ""
    @State private var isFilled: Bool = false

    var body: some View {
        VStack {
            CanvasView(canvasItem: canvasItem,
                       selectedColor: $selectedColor,
                       currentMode: $currentMode,
                       strokeWidth: $strokeWidth,
                       fontSize: $fontSize,
                       userText: $userText,
                       isFilled: $isFilled)
                .frame(maxWidth: .infinity)
                .aspectRatio(600.0 / 448.0, contentMode: .fit)
                .background(Color.tertiaryRow)
                .padding(.all, 4.0)
            
            PaintToolsView(canvasItem: canvasItem,
                           selectedColor: $selectedColor,
                           currentMode: $currentMode,
                           strokeWidth: $strokeWidth,
                           fontSize: $fontSize,
                           userText: $userText,
                           isFilled: $isFilled)
            .padding(.all, 5.0)
        }
        .shareButton(imageProcessor: canvasItem)
    }

    private func saveCanvasAsImage() {
        if let image = createCanvasImage(size: CGSize(width: 600.0, height: 448.0), scale: UIScreen.main.scale) {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: image)
        }
    }

    private func prepareCanvasForUpload() -> UIImage? {
        guard let image = createCanvasImage(size: CGSize(width: 600.0, height: 448.0), scale: 1.0) else {
            return nil
        }
        return image
    }

    private func createCanvasImage(size: CGSize, scale: CGFloat) -> UIImage? {
        if let canvasImage = canvasItem.createCanvasImage(size: size, scale: scale) {
            return canvasImage
        } else {
            print("Error while attempting to create image from canvasItem, please check logs")
            return nil
        }
    }

    private func saveCanvasItem() {
        if let server = appSettings.currentServer {
            if !server.canvasHistoryItems.contains(canvasItem) {
                server.canvasHistoryItems.append(canvasItem)
                modelContext.insert(canvasItem)
                print("Before save:")
                print("ID: \(canvasItem.id)")
                print("Paths: \(canvasItem.paths)")
                print("Shapes: \(canvasItem.shapes)")
                print("Background Color: \(canvasItem.backgroundColor)")
                print("Text Entries: \(canvasItem.textEntries)")
                canvasItem.lastEditDate = Date()
                try? modelContext.save()
                print("After save:")
                print("ID: \(canvasItem.id)")
                print("Paths: \(canvasItem.paths)")
                print("Shapes: \(canvasItem.shapes)")
                print("Background Color: \(canvasItem.backgroundColor)")
                print("Text Entries: \(canvasItem.textEntries)")
                print("Last Edit Date: \(canvasItem.lastEditDate)")
            }
        } else {
            print("No server selected to save canvasItem into history list")
        }
    }

    private func resetCanvas() {
        canvasItem.textEntries.removeAll()
        canvasItem.paths.removeAll()
        canvasItem.shapes.removeAll()
        canvasItem.backgroundColor = "white"
        canvasItem.canvasWidth = 600
        canvasItem.canvasHeight = 448
    }
}
