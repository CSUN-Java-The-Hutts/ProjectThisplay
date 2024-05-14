//
//  HBlockStatusView.swift
//  ThisPlay
//
import Foundation
import SwiftUI

struct HorizontalBlockStatusView: View {
    let blockStatuses: [String]

    var body: some View {
        
        let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 8)

        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(blockStatuses.indices, id: \.self) { index in
                VStack {
                    Text("#\(index + 1)")
                    Image(systemName: statusIcon(for: blockStatuses[index]))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(statusColor(for: blockStatuses[index]))
                }
                .frame(width: 40, height: 70)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    private func statusIcon(for status: String) -> String {
        if status.contains("200") {
            return "checkmark.circle.fill"
        } else if status.contains("Error") {
            return "xmark.octagon.fill"
        } else if status.contains("Retrying") {
            return "exclamationmark.triangle.fill"
        } else {
            return "clock.badge.questionmark.fill"
        }
    }

    private func statusColor(for status: String) -> Color {
        if status.contains("200") {
            return .green
        } else if status.contains("Error") {
            return .red
        } else if status.contains("Retrying") {
            return .yellow
        } else {
            return .gray
        }
    }
}

struct HorizontalBlockStatusView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalBlockStatusView(blockStatuses: [
            "200", "Error", "Retrying", "Pending",
            "200", "Error", "Retrying", "Pending"
        ])
        .previewLayout(.sizeThatFits)
    }
}
