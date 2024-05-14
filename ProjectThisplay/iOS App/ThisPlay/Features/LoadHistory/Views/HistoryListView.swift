//
//  HistoryListView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appSettings: AppSettings
    @Bindable var selectedServer: Server
    @State private var selectedMode: Mode = .canvas
    @State private var sortOrder: SortOrder = .latestFirst
    
    enum Mode: String, CaseIterable, Identifiable {
        case canvas, text, image
        var id: String { self.rawValue }
    }
    
    enum SortOrder: String, CaseIterable, Identifiable {
        case latestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        var id: String { self.rawValue }
    }
    
    var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Sort Items By: ")
                    .frame(alignment: .leading)
                Spacer()
                Picker("Sort Order", selection: $sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(alignment: .trailing)
            }
            .padding(.horizontal)
            
            Picker("Select Mode", selection: $selectedMode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            List {
                if let items = fetchHistoryItems(for: selectedServer, mode: selectedMode) {
                    ForEach(items) { anyHistoryItem in
                        NavigationLink(destination: editView(for: anyHistoryItem)) {
                            Text("\(anyHistoryItem.lastEditDate, formatter: itemFormatter)")
                        }
                    }
                    .onDelete(perform: deleteHistoryItem)
                } else {
                    Text("No items found.")
                }
            }
        }
        .navigationTitle("History")
    }
    
    func fetchHistoryItems(for server: Server, mode: Mode) -> [AnyHistoryItem]? {
        let items: [any HistoryItem]
        
        switch mode {
        case .canvas:
            items = server.canvasHistoryItems
        case .text:
            items = server.textHistoryItems
        case .image:
            items = server.imageHistoryItems
        }
        
        let sortedItems = items.sorted {
            sortOrder == .latestFirst ? $0.lastEditDate > $1.lastEditDate : $0.lastEditDate < $1.lastEditDate
        }

        return sortedItems.map { AnyHistoryItem($0) }
    }
    
    func deleteHistoryItem(_ indexSet: IndexSet) {
        for index in indexSet {
            switch selectedMode {
            case .canvas:
                modelContext.delete(selectedServer.canvasHistoryItems[index])
            case .text:
                modelContext.delete(selectedServer.textHistoryItems[index])
            case .image:
                modelContext.delete(selectedServer.imageHistoryItems[index])
            }
        }
    }
    
    @ViewBuilder
    func editView(for anyHistoryItem: AnyHistoryItem) -> some View {
        if let canvasItem = anyHistoryItem.item as? CanvasItem {
            PaintModeView(appSettings: appSettings, canvasItem: canvasItem)
        } else if let textItem = anyHistoryItem.item as? TextItem {
            TextModeView(appSettings: appSettings, textItem: textItem)
        } else if let imageItem = anyHistoryItem.item as? ImageItem {
            ImageModeView(appSettings: appSettings, imageItem: imageItem)
        } else {
            Text("Unknown item type")
        }
    }
}
