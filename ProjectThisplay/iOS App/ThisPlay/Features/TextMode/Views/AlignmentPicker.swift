//
//  AlignmentPicker.swift
//  ThisPlay
//
import Foundation
import SwiftUI

struct AlignmentPicker<AlignmentOption: CaseIterable & Identifiable & Hashable>: View where AlignmentOption.AllCases: RandomAccessCollection {
    let title: String
    let selection: Binding<AlignmentOption>
    let options: AlignmentOption.AllCases
    let symbolName: (AlignmentOption) -> String

    var body: some View {
        VStack {
            if !title.isEmpty {
                Text(title)
                    .frame(alignment: .center)
            }
            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Image(systemName: symbolName(option))
                        .tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5.0)
    }
}

struct AlignmentPicker_Previews: PreviewProvider {
    enum AlignmentOption: String, CaseIterable, Identifiable {
        case left, center, right

        var id: String { self.rawValue }
    }
    
    @State static var selectedAlignment: AlignmentOption = .center

    static var previews: some View {
        VStack {
            AlignmentPicker(
                title: "Text Alignment",
                selection: $selectedAlignment,
                options: AlignmentOption.allCases,
                symbolName: { option in
                    switch option {
                    case .left: return "text.alignleft"
                    case .center: return "text.aligncenter"
                    case .right: return "text.alignright"
                    }
                }
            )

            AlignmentPicker(
                title: "",
                selection: $selectedAlignment,
                options: AlignmentOption.allCases,
                symbolName: { option in
                    switch option {
                    case .left: return "text.alignleft"
                    case .center: return "text.aligncenter"
                    case .right: return "text.alignright"
                    }
                }
            )
        }
    }
}
