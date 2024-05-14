//
//  SettingsView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showingResetAlert = false
    @State private var currentIconName: String?
    @Query var servers: [Server]
    @Query var appSettingsList: [AppSettings]
    // Computed property to get the appSettings
    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("App Icon")) {
                    NavigationLink(destination: AppIconView()) {
                        HStack {
                            Text("Change App Icon")
                            Spacer()
                            Image(uiImage: loadCurrentIconImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Section(header: Text("Default Server")) {
                    if let defaultServer = servers.filter({ $0.isDefault }).first {
                        NavigationLink(destination: EditServerView(server: defaultServer)) {
                            VStack(alignment: .leading) {
                                Text("Nickname: \(defaultServer.nickname)")
                                    .font(.headline)
                                Text("IP Address: \(defaultServer.ipAddress)")
                                    .font(.subheadline)
                            }
                        }
                    } else {
                        Text("No default server selected")
                    }
                    NavigationLink("Select Default Server", destination: SelectServerView(allowSetDefault: true))
                }
                
                Section(header: Text("Active Server")) {
                    if let selectedServer = appSettings.currentServer {
                        NavigationLink(destination: EditServerView(server: selectedServer)) {
                            VStack(alignment: .leading) {
                                Text("Nickname: \(selectedServer.nickname)")
                                    .font(.headline)
                                Text("IP Address: \(selectedServer.ipAddress)")
                                    .font(.subheadline)
                            }
                        }
                    } else {
                        Text("No active server selected")
                    }
                    NavigationLink("Reset Server History", destination: Text("Reset Server History View Placeholder"))
                }
                
                // Next section is for adding and changing the active server
                Section(header: Text("Server Management")) {
                    NavigationLink("Add New Server", destination: EditServerView(server: nil))
                    NavigationLink("Change Active Server", destination: SelectServerView(allowSetDefault: false))
                }
                
                Button("Reset All Data") {
                    showingResetAlert = true
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                let iconName = UserDefaults.standard.string(forKey: "selectedAppIcon")
                currentIconName = iconName
            }
            .alert("Confirm Reset", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to reset all data?\n\n This will delete all server information and history items that have not yet been saved to the user photo library.\n\n This action cannot be undone, and the app will close on completion.")
            }
        }
    }
    
    func loadCurrentIconImage() -> UIImage {
        let iconName = UserDefaults.standard.string(forKey: "selectedAppIcon")
        if let iconName = iconName, !iconName.isEmpty, let image = UIImage(named: iconName) {
            return image
        }
        return UIImage(named: "AppIcon") ?? UIImage(systemName: "app")!
    }
    
    func resetAllData() {
        do {
            // Delete all data logic here
            try modelContext.delete(model: Server.self)
            try modelContext.delete(model: TextItem.self)
            try modelContext.delete(model: CanvasItem.self)
            try modelContext.delete(model: ImageItem.self)
            // Force exit the app
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                exit(0)
            }
        } catch {
            print("Failed to clear Server & History data")
        }
    }
}
