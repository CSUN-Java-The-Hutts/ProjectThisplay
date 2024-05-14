//
//  DrawingModels.swift
//  ThisPlay
//
import SwiftUI

// enum to define different drawing tools/modes
enum DrawingMode: String {
    
    case freeform, text, fill, drawCircle, drawRectangle

    var description: String {
        switch self {
        case .freeform: return "Freeform"
        case .text: return "Text"
        case .fill: return "Fill"
        case .drawCircle: return "Draw Circle"
        case .drawRectangle: return "Draw Rectangle"
        }
    }
}

// enum used to retrieve the z-index/layer order from our various objects
enum DrawableElement {
    case text(TextEntry)
    case path(DrawingPath)
    case shape(DrawingShape)
    
    var zIndex: Int {
        switch self {
        case .text(let entry): return entry.zIndex
        case .path(let path): return path.zIndex
        case .shape(let shape): return shape.zIndex
        }
    }
}

// struct for canvas text entries items
struct TextEntry: Codable {
    var text: String
    var position: CGPoint
    var fontSize: CGFloat
    var colorName: String
    var zIndex: Int

    enum CodingKeys: String, CodingKey {
        case text, position, fontSize, colorName, zIndex
    }
    
    init(text: String, position: CGPoint, fontSize: CGFloat, colorName: String, zIndex: Int) {
        self.text = text
        self.position = position
        self.fontSize = fontSize
        self.colorName = colorName
        self.zIndex = zIndex
    }
}


// Codable conformance for ShapeType
enum ShapeType {
    case circle
    case rectangle
    // Additional shapes can be added here.
}

extension ShapeType: Codable {
    // Implement Codable manually to handle the enum
    enum CodingKeys: CodingKey {
        case rawValue
    }

    enum RawValues: String, Codable {
        case circle
        case rectangle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(RawValues.self, forKey: .rawValue)
        switch rawValue {
        case .circle:
            self = .circle
        case .rectangle:
            self = .rectangle
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let rawValue = RawValues(rawValue: String(describing: self))!
        try container.encode(rawValue, forKey: .rawValue)
    }
}

// Codable conformance for DrawingShape
struct DrawingShape: Codable, Hashable {
    var type: ShapeType
    var rect: CGRect
    var colorName: String
    var isFilled: Bool
    var lineWidth: CGFloat
    var zIndex: Int

    init(type: ShapeType, rect: CGRect, colorName: String, isFilled: Bool, lineWidth: CGFloat, zIndex: Int) {
        self.type = type
        self.rect = rect
        self.colorName = colorName
        self.isFilled = isFilled
        self.lineWidth = lineWidth
        self.zIndex = zIndex
    }

    enum CodingKeys: String, CodingKey {
        case type, rect, colorName, isFilled, lineWidth, zIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ShapeType.self, forKey: .type)
        rect = try container.decode(CGRect.self, forKey: .rect)
        colorName = try container.decode(String.self, forKey: .colorName)
        isFilled = try container.decode(Bool.self, forKey: .isFilled)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        zIndex = try container.decode(Int.self, forKey: .zIndex)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(rect, forKey: .rect)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(isFilled, forKey: .isFilled)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(zIndex, forKey: .zIndex)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(rect.origin.x)
        hasher.combine(rect.origin.y)
        hasher.combine(rect.size.width)
        hasher.combine(rect.size.height)
        hasher.combine(isFilled)
        hasher.combine(lineWidth)
    }
    
    static func == (lhs: DrawingShape, rhs: DrawingShape) -> Bool {
        return lhs.type == rhs.type &&
               lhs.rect == rhs.rect &&
               lhs.colorName == rhs.colorName &&
               lhs.isFilled == lhs.isFilled &&
               lhs.lineWidth == rhs.lineWidth
    }
}

// Codable conformance for DrawingPath
struct DrawingPath: Codable, Hashable {
    var points: [CGPoint]
    var colorName: String
    var lineWidth: CGFloat
    var zIndex: Int
        
    // Explicitly define a basic initializer
    init(points: [CGPoint], colorName: String, lineWidth: CGFloat, zIndex: Int) {
        self.points = points
        self.colorName = colorName
        self.lineWidth = lineWidth
        self.zIndex = zIndex
    }

    enum CodingKeys: String, CodingKey {
        case points, colorName, lineWidth, zIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        points = try container.decode([CGPoint].self, forKey: .points)
        colorName = try container.decode(String.self, forKey: .colorName)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        zIndex = try container.decode(Int.self, forKey: .zIndex)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(zIndex, forKey: .zIndex)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(points.map { $0.x.hashValue ^ $0.y.hashValue })
        hasher.combine(lineWidth)
    }
    
    static func == (lhs: DrawingPath, rhs: DrawingPath) -> Bool {
        return lhs.points == rhs.points && lhs.colorName == rhs.colorName && lhs.lineWidth == rhs.lineWidth
    }
}
