//
//  HistoryItem.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

// Protocol to be shared by all history item types
protocol HistoryItem: Identifiable {
    var lastEditDate: Date { get }
}

struct AnyHistoryItem: Identifiable {
    let id: AnyHashable
    let item: Any
    let lastEditDate: Date
    
    init<T: HistoryItem>(_ historyItem: T) {
        self.id = AnyHashable(historyItem.id)
        self.item = historyItem
        self.lastEditDate = historyItem.lastEditDate
    }
}

