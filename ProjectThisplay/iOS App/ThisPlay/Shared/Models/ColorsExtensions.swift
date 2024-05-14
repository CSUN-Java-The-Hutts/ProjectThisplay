//
//  ColorsExtensions.swift
//  ThisPlay
//
import SwiftUI
import UIKit
import CoreImage
import DitheringEngine

struct EPDColors {
    static let white = "EPD_7_White"
    static let blank = "EPD_7_Blank"
    static let black = "EPD_7_Black"
    static let red = "EPD_7_Red"
    static let orange = "EPD_7_Orange"
    static let yellow = "EPD_7_Yellow"
    static let green = "EPD_7_Green"
    static let blue = "EPD_7_Blue"

    static let friendlyNames: [String: String] = [
        "EPD_7_White": "White",
        "EPD_7_Blank": "Blank",
        "EPD_7_Black": "Black",
        "EPD_7_Red": "Red",
        "EPD_7_Orange": "Orange",
        "EPD_7_Yellow": "Yellow",
        "EPD_7_Green": "Green",
        "EPD_7_Blue": "Blue"
    ]
    
    static let colorNames = [
        white, blank, black,
        red, orange, yellow,
        green, blue
    ]
    
    // Map colors to their respective codes
    static let colorCodes: [String: UInt8] = [
        "Black": 0x00,
        "White": 0x01,
        "Green": 0x02,
        "Blue": 0x03,
        "Red": 0x04,
        "Yellow": 0x05,
        "Orange": 0x06,
        "Blank": 0x07
    ]

    static func code(for colorName: String) -> UInt8? {
        return colorCodes[colorName]
    }

    static func code(for color: Color) -> UInt8? {
        let colorName = Color.name(from: color)
        if let friendlyName = friendlyNames[colorName] {
            return colorCodes[friendlyName]
        }
        return nil
    }
    
    static func rgbComponents(for colorName: String) -> [UInt8]? {
        guard let color = UIColor(named: colorName),
              let components = color.cgColor.components,
              components.count >= 3 else {
            print("Failed to load color: \(colorName)")
            return nil
        }
        return components.map { UInt8($0 * 255) }
    }
    
    // Construct the color palette using fetched components
    static let paletteColors: [String: [UInt8]] = {
        var colors: [String: [UInt8]] = [:]
        for name in EPDColors.colorNames {
            if let components = EPDColors.rgbComponents(for: name) {
                colors[EPDColors.friendlyNames[name] ?? name] = components
            }
        }
        return colors
    }()
    // now create the actual bytepalette that dithering engine needs
    static let paletteColorsArray: [SIMD3<UInt8>] = paletteColors.values.map { SIMD3($0[0], $0[1], $0[2]) }
    static let collection = LUTCollection<UInt8>(entries: paletteColorsArray)
    static let palette = BytePalette.from(lutCollection: collection)
}

extension Color {
    var uiColor: UIColor {
        return UIColor(self)
    }
    
    var safeCGColor: CGColor {
        return self.uiColor.cgColor
    }
    
    private func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
    
    // override the default color mappings to use our e-paper safe colors
    static func color(from name: String) -> Color {
        switch name {
        case EPDColors.white:
            return Color("EPD_7_White")
        case EPDColors.blank:
            return Color("EPD_7_Blank")
        case EPDColors.black:
            return Color("EPD_7_Black")
        case EPDColors.red:
            return Color("EPD_7_Red")
        case EPDColors.orange:
            return Color("EPD_7_Orange")
        case EPDColors.yellow:
            return Color("EPD_7_Yellow")
        case EPDColors.green:
            return Color("EPD_7_Green")
        case EPDColors.blue:
            return Color("EPD_7_Blue")
        default:
            return Color("EPD_7_Blank")
        }
    }
    
    static func name(from color: Color) -> String {
        switch color {
        case .white:
            return EPDColors.white
        case .gray:
            return EPDColors.blank
        case .black:
            return EPDColors.black
        case .red:
            return EPDColors.red
        case .orange:
            return EPDColors.orange
        case .yellow:
            return EPDColors.yellow
        case .green:
            return EPDColors.green
        case .blue:
            return EPDColors.blue
        default:
            return EPDColors.blank
        }
    }
}

extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        let hexString = String(format: "#%02lX%02lX%02lX",
                               lroundf(r * 255),
                               lroundf(g * 255),
                               lroundf(b * 255))
        return hexString
    }
}

extension EPDColors {
    static func hexValue(for colorName: String) -> String? {
        guard let color = UIColor(named: colorName) else { return nil }
        return color.toHex()
    }
}
