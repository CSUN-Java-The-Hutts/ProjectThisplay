//
//  EditServerView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct EditServerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode
    @State var server: Server?
    @State private var nickname: String = ""
    @State private var ipAddress: String = ""
    @State private var isDefault: Bool = false
    @Query var appSettingsList: [AppSettings]

    var isEditMode: Bool {
        server != nil
    }
    
    // Computed property to get the appSettings
    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Nickname", text: $nickname)
                TextField("IP Address", text: $ipAddress)
                Toggle("Set as Default", isOn: $isDefault)
            }
            .navigationBarTitle(isEditMode ? "Edit Server" : "Add Server", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Save") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            loadServerData()
        }
    }
    
    func loadServerData() {
        if let existingServer = server {
            // Load existing server data if in edit mode
            nickname = existingServer.nickname
            ipAddress = existingServer.ipAddress
            isDefault = existingServer.isDefault
        }
    }
    
    func saveChanges() {
        guard !nickname.isEmpty, !ipAddress.isEmpty else { return }
        let serverToSave = server ?? Server()
        serverToSave.nickname = nickname
        serverToSave.ipAddress = ipAddress
        serverToSave.isDefault = isDefault
        
        if isDefault {
            appSettings.defaultServer = serverToSave
        }
        
        withAnimation {
            if server == nil {
                modelContext.insert(serverToSave)
            }
            try? modelContext.save()
            print(serverToSave.id)
            appSettings.currentServer = serverToSave
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AppSettings.self, Server.self, configurations: config)

        let exampleAppSettings = AppSettings()
        container.mainContext.insert(exampleAppSettings)

        let exampleServer = Server(nickname: "Example!", ipAddress: "192.168.1.247", isDefault: false)
        container.mainContext.insert(exampleServer)

        return EditServerView(server: exampleServer)
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
