//
//  LaunchView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State private var showCreateMenu = false
    @State private var showSettingsView = false
    @State private var showHistoryView = false
    @State private var selectedCanvasItem: CanvasItem? = nil
    @State private var selectedTextItem: TextItem? = nil
    @State private var selectedImageItem: ImageItem? = nil
    @State private var selectedServer: Server? = nil
    @Query var appSettingsList: [AppSettings]
    @Query var serversList: [Server]
    // computed propery to always grab our app settings instance
    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: UIImage(named: "AppName")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 15.0)
                    .padding(.vertical, 20.0)
                
                cardView(action: { showCreateMenu = true }, title: "Create New Image", backgroundColor: Color.purple)
                    .actionSheet(isPresented: $showCreateMenu) {
                        ActionSheet(title: Text("Select Mode"), buttons: [
                            .default(Text("Canvas Mode")) {
                                selectedCanvasItem = CanvasItem()
                                selectedServer?.canvasHistoryItems.append(selectedCanvasItem!)
                            },
                            .default(Text("Text Mode")) {
                                selectedTextItem = TextItem()
                                selectedServer?.textHistoryItems.append(selectedTextItem!)
                            },
                            .default(Text("Image Mode")) {
                                selectedImageItem = ImageItem()
                                selectedServer?.imageHistoryItems.append(selectedImageItem!)
                            },
                            .cancel()
                        ])
                    }
                
                cardView(action: { showHistoryView = true }, title: "Load Saved Item", backgroundColor: Color.teal)
                    .navigationDestination(isPresented: $showHistoryView) {
                        if let server = selectedServer {
                            HistoryView(appSettings: appSettings, selectedServer: server)
                        } else {
                            Text("No server selected")
                        }
                    }
                VStack(alignment: .center) {
                    Text("ThisPlay Server: ")
                    Picker("Select Server", selection: $selectedServer) {
                        ForEach(serversList) { server in
                            Text(server.nickname).tag(server as Server?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onAppear {
                        if selectedServer == nil, let lastServer = appSettings.currentServer {
                            selectedServer = lastServer
                        } else if let firstServer = serversList.first {
                            selectedServer = firstServer
                            appSettings.currentServer = selectedServer
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedCanvasItem != nil },
                set: { if !$0 { selectedCanvasItem = nil } }
            )) {
                if let item = selectedCanvasItem {
                    PaintModeView(appSettings: appSettings, canvasItem: item)
                }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedTextItem != nil },
                set: { if !$0 { selectedTextItem = nil } }
            )) {
                if let item = selectedTextItem {
                    TextModeView(appSettings: appSettings, textItem: item)
                }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedImageItem != nil },
                set: { if !$0 { selectedImageItem = nil } }
            )) {
                if let item = selectedImageItem {
                    ImageModeView(appSettings: appSettings, imageItem: item)
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
    
    private func cardView(action: @escaping () -> Void, title: String, backgroundColor: Color) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor.opacity(0.7),
                        backgroundColor.opacity(0.85),
                        backgroundColor.opacity(1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(10)
                .frame(height: 200)
                Text(title)
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.colorScheme, .light)
                .modelContainer(setupMockModelContainer())

            ContentView()
                .environment(\.colorScheme, .dark)
                .modelContainer(setupMockModelContainer())
        }
    }
    
    static func setupMockModelContainer() -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: Server.self, AppSettings.self, TextItem.self, CanvasItem.self, ImageItem.self, configurations: config)
            // Creating mock Server data
            let example1 = Server(nickname: "PEETS!", ipAddress: "192.168.1.247", isDefault: false)
            let example2 = Server(nickname: "CHONKER", ipAddress: "192.168.1.247", isDefault: true)
            let example3 = Server(nickname: "SQUISHBEANS", ipAddress: "192.168.1.247", isDefault: false)
            
            container.mainContext.insert(example1)
            container.mainContext.insert(example2)
            container.mainContext.insert(example3)
            return container
        } catch {
            fatalError("Failed to create mock model container.")
        }
    }
}
