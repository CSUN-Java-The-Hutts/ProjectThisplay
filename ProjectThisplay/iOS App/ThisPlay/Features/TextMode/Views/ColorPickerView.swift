import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: String
    let colorOptions: [String]
    
    // Default color names
    static let defaultColorOptions = [
        EPDColors.white, EPDColors.blank, EPDColors.black,
        EPDColors.red, EPDColors.orange, EPDColors.yellow,
        EPDColors.green, EPDColors.blue
    ]
    
    init(selectedColor: Binding<String>, colorOptions: [String] = defaultColorOptions) {
        self._selectedColor = selectedColor
        self.colorOptions = colorOptions
    }
    
    var body: some View {
        Picker("Select Color", selection: $selectedColor) {
            ForEach(colorOptions, id: \.self) { colorName in
                Text(EPDColors.friendlyNames[colorName] ?? colorName)
                    .foregroundColor(Color.color(from: colorName))
                    .tag(colorName)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    @State static var selectedColor = EPDColors.black
    
    static var previews: some View {
        // Use default colors
        ColorPickerView(selectedColor: $selectedColor)
    }
}
