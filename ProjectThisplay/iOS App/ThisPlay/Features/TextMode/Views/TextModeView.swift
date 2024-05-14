//
//  TextModeView.swift
//  ThisPlay
//
// TextModeView.swift
import SwiftUI
import SwiftData

struct TextModeView: View {
    static let overlayHelpText: String = "Text you enter below will be displayed here, as it will appear on your e-paper device. You can adjust positioning and text size to fit your readability preference."
    @Environment(\.modelContext) var modelContext
    @Bindable var appSettings: AppSettings
    @Bindable var textItem: TextItem
    @State private var currentWidth: CGFloat = 600 // Default value
    @State private var currentHeight: CGFloat = 448 // Default value based on aspect ratio
    @State private var showingUploadSheet = false
    @State private var currentTextItem: TextItem? = nil
    @State private var displayText: String = TextModeView.overlayHelpText

    // DateFormatter configuration
    var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // Example: Nov 23, 1937
        formatter.timeStyle = .short  // Example: 3:30 PM
        return formatter
    }

    var textAlignment: Alignment {
        Alignment(horizontal: textItem.horizontalAlignment.alignment, vertical: textItem.verticalAlignment.alignment)
    }
    
    var textAlignmentForMultiline: TextAlignment {
        switch textItem.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
    
    var baseFontSizePoints: CGFloat {
        16.6 / (132.5 / 72)
    }
    
    var currentFontSizePixels: CGFloat {
        16.6 * textItem.scaleFactor
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Color.color(from: textItem.backgroundColor)
                    .aspectRatio(1.34, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: textAlignment) {
                        Text(textItem.text.isEmpty ? displayText : textItem.text)
                            .font(.system(size: baseFontSizePoints * textItem.scaleFactor))
                            .foregroundColor(Color.color(from: textItem.textColor))
                            .padding(3.0)
                            .lineLimit(nil)  // Allow for multiple lines
                            .multilineTextAlignment(textAlignmentForMultiline)
                    }
                    .clipped()  // Ensure the text does not go outside the bounds
                    .onAppear {
                        updateViewSize(width: geometry.size.width, height: geometry.size.width / 1.34)
                    }
                    .onChange(of: geometry.size) {
                        updateViewSize(width: geometry.size.width, height: geometry.size.width / 1.34)
                    }
                
                TextToolsView(textItem: textItem,
                              displayText: $displayText,
                              currentFontSizePixels: currentFontSizePixels,
                              baseFontSizePoints: baseFontSizePoints,
                              geometry: geometry
                )
                .padding(.vertical, 10.0)
                .padding(.horizontal, 5.0)
                .background(.tertiaryRow.opacity(0.65))
                .cornerRadius(10, corners: [.bottomLeft, .bottomRight])

                EqualWidthHStack {

                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width) // Explicitly set the frame width to ensure centering
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .gesture(DragGesture().onChanged { _ in
                hideKeyboard()
            })
        }
        .shareButton(imageProcessor: textItem)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func updateViewSize(width: CGFloat, height: CGFloat) {
        currentWidth = width
        currentHeight = height
        print("Updated view Size: Width = \(width), Height = \(height)")
    }
    
    private func saveTextItem() {
        textItem.lastEditDate = Date()
        try? modelContext.save()
        print(textItem.id)
    }
    
    func saveTextAsImage() {
        if let image = textItem.renderTextToImage(scale: UIScreen.main.scale) {
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: image)
        }
    }
    
    
    private func prepareTextForUpload() -> UIImage? {
        guard let image = textItem.renderTextToImage(scale: 1.0) else {
            return nil
        }
        return image
    }
    
    private func resetText() {
        textItem.text = ""
        displayText = TextModeView.overlayHelpText
        textItem.scaleFactor = 2.50
        textItem.horizontalAlignment = .center
        textItem.verticalAlignment = .center
        textItem.textColor = EPDColors.black
        textItem.backgroundColor = EPDColors.white
        currentTextItem = nil
    }
}
