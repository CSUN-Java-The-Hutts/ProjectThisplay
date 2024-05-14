//
//  AlignmentOptions.swift
//  ThisPlay
//
//  Created by Jocelyn Mallon on 5/7/24.
//

import Foundation
import SwiftUI

enum HorizontalOption: Int, CaseIterable, Identifiable, Codable {
    case leading, center, trailing

    var id: Int { self.rawValue }
    
    var alignment: HorizontalAlignment {
        switch self {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    var symbolName: String {
        switch self {
        case .leading:
            return "text.alignleft"
        case .center:
            return "text.aligncenter"
        case .trailing:
            return "text.alignright"
        }
    }
}

enum VerticalOption: Int, CaseIterable, Identifiable, Codable {
    case top, center, bottom

    var id: Int { self.rawValue }
    
    var alignment: VerticalAlignment {
        switch self {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }

    var symbolName: String {
        switch self {
        case .top:
            return "align.vertical.top"
        case .center:
            return "align.vertical.center"
        case .bottom:
            return "align.vertical.bottom"
        }
    }
}

extension NSTextAlignment {
    init(_ textAlignment: TextAlignment) {
        switch textAlignment {
        case .leading:
            self = .left
        case .center:
            self = .center
        case .trailing:
            self = .right
        }
    }
}
