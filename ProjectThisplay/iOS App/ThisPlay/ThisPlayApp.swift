//
//  ThisPlayApp.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

@main
struct ThisPlayApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        //.modelContainer(for: [AppSettings.self, Server.self, CanvasItem.self, TextItem.self, ImageItem.self], isAutosaveEnabled: false)
        .modelContainer(for: [AppSettings.self, Server.self, CanvasItem.self, TextItem.self, ImageItem.self])
    }
}
