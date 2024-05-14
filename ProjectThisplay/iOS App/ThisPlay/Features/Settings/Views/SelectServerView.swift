//
//  ServerSelectionView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct SelectServerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Query(sort: [SortDescriptor(\Server.nickname)]) var savedServers: [Server]
    @Query var appSettingsList: [AppSettings]
    var allowSetDefault: Bool
    
    // Computed property to get the appSettings
    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(savedServers) { server in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(server.nickname)
                                .font(.headline)
                            Text(server.ipAddress)
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: server.isDefault ? "star.fill" : "star")
                            .foregroundColor(server.isDefault ? .yellow : .gray)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if allowSetDefault {
                            setDefaultServer(server: server)
                        } else {
                            appSettings.currentServer = server
                            try? modelContext.save()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationBarTitle(allowSetDefault ? "Set Default Server" : "Change Active Server")
        }
    }
    
    func setDefaultServer(server: Server) {
        if !server.isDefault {  // Only change if it's not already default
            for index in savedServers.indices {
                savedServers[index].isDefault = savedServers[index].id == server.id
            }
            try? modelContext.save()
            print(server.id, server.isDefault)
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

        return SelectServerView(allowSetDefault: true)
        .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
