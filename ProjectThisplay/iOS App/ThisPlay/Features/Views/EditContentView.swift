//
//  EditContentView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct EditContentView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var textItem: TextItem?
    @Binding var imageItem: ImageItem?
    @Query var appSettingsList: [AppSettings]
    
    @State private var selectedTab: Int = 0

    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }

    var body: some View {

        return TabView(selection: $selectedTab) {
        }
        .navigationTitle(tabTitle)
    }
    
    
    private var tabTitle: String {
        switch selectedTab {
        case 0:
            return "Paint Mode"
        case 1:
            return "Text Mode"
        case 2:
            return "Photo Mode"
        default:
            return "Edit"
        }
    }
}
