//
//  PaletteView.swift
//  ThisPlay
//
import SwiftUI

struct PaletteView: View {
    @Binding var selectedColor: String
    let colorNames: [String]

    var body: some View {
        EqualWidthHStack {
            ForEach(colorNames, id: \.self) { colorName in
                ColorButton(color: Color(colorName), isSelected: selectedColor == colorName) {
                    selectedColor = colorName
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ColorButton: View {
    var color: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        color
            .border(isSelected ? Color.accentColor : Color.gray, width: isSelected ? 3 : 1)
            .cornerRadius(2)  // Adds rounded corners for a smoother look
            .onTapGesture(perform: action)
            .aspectRatio(1.0, contentMode: .fit)
            .frame(minWidth: 40, maxWidth: .infinity, minHeight: 40)
    }
}
