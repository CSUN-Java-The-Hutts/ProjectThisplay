//
//  TextToolsView.swift
//  ThisPlay
//
import SwiftUI

struct TextToolsView: View {
    @Bindable var textItem: TextItem
    @Binding var displayText: String
    var currentFontSizePixels: CGFloat
    var baseFontSizePoints: CGFloat
    var geometry: GeometryProxy

    var body: some View {
        VStack {
            EqualWidthHStack {
                AlignmentPicker(
                    title: "",
                    selection: $textItem.verticalAlignment,
                    options: VerticalOption.allCases,
                    symbolName: { $0.symbolName }
                )
                .frame(width: (geometry.size.width / 2) - 10)
                AlignmentPicker(
                    title: "",
                    selection: $textItem.horizontalAlignment,
                    options: HorizontalOption.allCases,
                    symbolName: { $0.symbolName }
                )
                .frame(width: (geometry.size.width / 2) - 10)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2.0)
            .padding(.horizontal, 5.0)
            // now add our pickers and glyphs for color adjustments
            EqualWidthHStack {
                HStack {
                    Image(systemName: "a.square")
                        .foregroundColor(Color.color(from: textItem.textColor))
                        .font(.system(size: 24))
                    ColorPickerView(selectedColor: $textItem.textColor)
                }
                .frame(width: (geometry.size.width / 2) - 10)

                HStack {
                    Image(systemName: "a.square.fill")
                        .foregroundColor(Color.color(from: textItem.backgroundColor))
                        .font(.system(size: 24))
                    ColorPickerView(selectedColor: $textItem.backgroundColor)
                }
                .frame(width: (geometry.size.width / 2) - 10)

            }
            .padding(.vertical, 5.0)
            // now add our font size/scale slider
            Slider(value: $textItem.scaleFactor, in: 1.0...4.0, step: 0.25)
            .padding(.horizontal, 5.0)
            // now add our text label showing the approx font size
            Text("Approx. Font Size: \(currentFontSizePixels, specifier: "%.0f") px")
            // finally, add our editor control
            TextEditor(text: $textItem.text)
                .font(.body)
                .frame(height: 100)
                .border(Color.secondary, width: 1)
                .padding(.horizontal, 5.0)
        }
    }
}
