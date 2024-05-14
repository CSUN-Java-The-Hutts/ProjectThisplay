//
//  ControlsView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct PaintToolsView: View {
    @Bindable var canvasItem: CanvasItem
    @Binding var selectedColor: String
    @Binding var currentMode: DrawingMode
    @Binding var strokeWidth: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var userText: String
    @Binding var isFilled: Bool
    
    let colors: [String] = [
        EPDColors.white, EPDColors.blank, EPDColors.black,
        EPDColors.red, EPDColors.orange, EPDColors.yellow,
        EPDColors.green, EPDColors.blue
    ]

    var body: some View {
        VStack {
            ScrollView {
                PaletteView(selectedColor: $selectedColor, colorNames: colors)

                Picker("Drawing Mode", selection: $currentMode) {
                    Text("Path").tag(DrawingMode.freeform)
                    Text("Text").tag(DrawingMode.text)
                    Text("Fill").tag(DrawingMode.fill)
                    Text("Circle").tag(DrawingMode.drawCircle)
                    Text("Rectangle").tag(DrawingMode.drawRectangle)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 5.0)
                .frame(maxWidth: .infinity)

                switch currentMode {
                case .freeform:
                    Slider(value: $strokeWidth, in: 1...20, step: 1) {
                        Text("Stroke Width")
                    }
                    .padding(.horizontal, 5.0)
                    Text("Stroke width: \(Int(strokeWidth))")

                case .text:
                    Slider(value: $fontSize, in: 12...36, step: 1) {
                        Text("Font Size")
                    }
                    .padding(.horizontal, 5.0)
                    Text("Font size: \(Int(fontSize))")
                    TextField("Enter text", text: $userText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.secondaryRow)
                    Text("(Tap on the canvas where you would like to place the entered text)")
                    
                case .fill:
                    Text("(Tap the canvas to change the background color to the selected color.)")
                case .drawCircle, .drawRectangle:
                    Toggle("Filled", isOn: $isFilled)
                        .padding(.horizontal, 5.0)
                    Slider(value: $strokeWidth, in: 1...10) {
                        Text("Stroke Width: \(strokeWidth, specifier: "%.1f")")
                    }
                    .padding(.horizontal, 5.0)

                }
            }
        }
    }
}

