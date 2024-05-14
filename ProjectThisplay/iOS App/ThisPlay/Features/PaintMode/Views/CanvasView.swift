//
//  CanvasView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct CanvasView: View {
    @Bindable var canvasItem: CanvasItem
    @Binding var selectedColor: String
    @Binding var currentMode: DrawingMode
    @Binding var strokeWidth: CGFloat
    @Binding var fontSize: CGFloat
    @Binding var userText: String
    @Binding var isFilled: Bool
    @State private var tempShape: DrawingShape?
    @State private var tempPath: DrawingPath?

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Fill the background first
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(canvasItem.backgroundColor)))

                // Draw each element based on its type
                for element in canvasItem.orderedElements {
                    switch element {
                    case .text(let entry):
                        let text = Text(entry.text)
                            .font(Font.system(size: entry.fontSize))
                            .foregroundColor(Color(entry.colorName))
                        context.draw(text, at: entry.position, anchor: .center)
                    case .path(let path):
                        var pathDrawing = Path()
                        pathDrawing.addLines(path.points)
                        context.stroke(pathDrawing, with: .color(Color(path.colorName)), lineWidth: path.lineWidth)
                    case .shape(let shape):
                        let path: Path = {
                            switch shape.type {
                            case .circle:
                                return Path(ellipseIn: shape.rect)
                            case .rectangle:
                                return Path(shape.rect)
                            }
                        }()
                        if shape.isFilled {
                            context.fill(path, with: .color(Color(shape.colorName)))
                        } else {
                            context.stroke(path, with: .color(Color(shape.colorName)), lineWidth: shape.lineWidth)
                        }
                    }
                }

                // Draw the temporary shape if it exists
                if let tempShape = tempShape {
                    let path: Path = {
                        switch tempShape.type {
                        case .circle:
                            return Path(ellipseIn: tempShape.rect)
                        case .rectangle:
                            return Path(tempShape.rect)
                        }
                    }()
                    if tempShape.isFilled {
                        context.fill(path, with: .color(Color(tempShape.colorName)))
                    } else {
                        context.stroke(path, with: .color(Color(tempShape.colorName)), lineWidth: tempShape.lineWidth)
                    }
                }

                // Draw the temporary path if it exists
                if let tempPath = tempPath {
                    var pathDrawing = Path()
                    pathDrawing.addLines(tempPath.points)
                    context.stroke(pathDrawing, with: .color(Color(tempPath.colorName)), lineWidth: tempPath.lineWidth)
                }
            }
            .aspectRatio(600.0 / 448.0, contentMode: .fit)
            .gesture(currentMode == .freeform ? dragGesture() : nil)
            .gesture((currentMode == .drawCircle || currentMode == .drawRectangle) ? shapeGesture() : nil)
            .gesture((currentMode == .text || currentMode == .fill) ? unifiedTapGesture() : nil)
            .onChange(of: geometry.size) { oldSize, newSize in
                canvasItem.updateCanvasSize(width: newSize.width, height: newSize.height)
            }
            .onAppear {
                canvasItem.updateCanvasSize(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private func unifiedTapGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded { value in
                switch currentMode {
                case .text:
                    // Add text centered at the location where the user tapped, with a new zIndex
                    let newTextEntry = TextEntry(
                        text: userText,
                        position: CGPoint(
                            x: value.location.x,
                            y: value.location.y
                        ),
                        fontSize: fontSize,
                        colorName: selectedColor,
                        zIndex: -1
                    )
                    canvasItem.addWithUniqueZIndex(for: .text(newTextEntry))
                case .fill:
                    // Update the background color of the canvas
                    canvasItem.backgroundColor = selectedColor
                default:
                    break
                }
            }
    }
    
    private func shapeGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let newPoint = value.location
                let rect = CGRect(origin: value.startLocation, size: CGSize(width: newPoint.x - value.startLocation.x, height: newPoint.y - value.startLocation.y))
                if currentMode == .drawCircle {
                    tempShape = DrawingShape(type: .circle, rect: rect, colorName: selectedColor, isFilled: isFilled, lineWidth: strokeWidth, zIndex: -1)
                } else if currentMode == .drawRectangle {
                    tempShape = DrawingShape(type: .rectangle, rect: rect, colorName: selectedColor, isFilled: isFilled, lineWidth: strokeWidth, zIndex: -1)
                }
            }
            .onEnded { value in
                if let completedShape = tempShape {
                    canvasItem.addWithUniqueZIndex(for: .shape(completedShape))
                    tempShape = nil // Ensure tempShape is cleared
                }
            }
    }

    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let newPoint = value.location
                if currentMode == .freeform {
                    if var lastPath = tempPath {
                        lastPath.points.append(newPoint)
                        tempPath = lastPath
                    } else {
                        tempPath = DrawingPath(points: [newPoint], colorName: selectedColor, lineWidth: strokeWidth, zIndex: -1)
                    }
                }
            }
            .onEnded { value in
                if let completedPath = tempPath {
                    canvasItem.addWithUniqueZIndex(for: .path(completedPath))
                    tempPath = nil // Ensure tempPath is cleared
                }
            }
    }

}
