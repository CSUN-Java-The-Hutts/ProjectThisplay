//
//  UploadImageView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct UploadImageView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var serverUploader: ServerUploader
    @State var uploadStatus: String = ""
    @State var showSuccessOverlay: Bool = false
    @State var showErrorOverlay: Bool = false
    @State var image: UIImage
    @Binding var isPresented: Bool

    @Query var appSettingsList: [AppSettings]
    var appSettings: AppSettings {
        appSettingsList.first ?? AppSettings()
    }

    init(image: UIImage, isPresented: Binding<Bool>) {
        _image = State(initialValue: image)
        _isPresented = isPresented

        let placeholderServer = Server(nickname: "", ipAddress: "", isDefault: false)
        _serverUploader = StateObject(wrappedValue: ServerUploader(server: placeholderServer, uploadStatusUpdate: { _ in }))
    }

    var body: some View {
        VStack {
            Text("Send Image to: \(appSettings.currentServer?.nickname ?? "Unknown")")
                            .font(.headline)
                            .padding()
            
            ImagePreview(image: image)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Server IP: \(appSettings.currentServer?.ipAddress ?? "N/A")")
                .padding(.top, 5)
                .foregroundColor(.gray)

            Text("Current Retries: \(serverUploader.currentRetries)")
                .padding(.top, 2)
                .foregroundColor(.gray)

            HorizontalBlockStatusView(blockStatuses: serverUploader.blockStatuses)
                .padding(.top, 10)

            Button(action: {
                uploadImage(image)
            }) {
                Text("Upload Image")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            uploadStatus = ""
            if let currentServer = appSettings.currentServer {
                serverUploader.server = currentServer
            }
        }
        .onChange(of: serverUploader.blockStatuses) { oldStatuses, newStatuses in
            uploadStatus = newStatuses.contains { $0.contains("Error") } ? "Upload failed" : newStatuses.allSatisfy { $0.contains("20") } ? "SUCCESS." : uploadStatus

            if uploadStatus == "SUCCESS." {
                showSuccessOverlay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessOverlay = false
                    isPresented = false
                }
            } else if uploadStatus == "Upload failed" {
                showErrorOverlay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showErrorOverlay = false
                }
            }
        }
        .overlay(overlayView())
    }

    private func overlayView() -> some View {
        Group {
            if showSuccessOverlay {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    Text("Upload Successful!")
                        .font(.title)
                        .foregroundColor(.green)
                }
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 10)
            } else if showErrorOverlay {
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)
                    Text("Upload Failed!")
                        .font(.title)
                        .foregroundColor(.red)
                }
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }

    private func uploadImage(_ image: UIImage) {
        guard let currentServer = appSettings.currentServer else {
            uploadStatus = "No server selected."
            return
        }
        serverUploader.server = currentServer
        let imageColors = ImageUtils.distinctColors(image: image)
        let colorInfos: [ColorInfo] = imageColors.compactMap { color in
            guard let hex = color.toHex() else { return nil }
            return ColorInfo(color: color, hexValue: hex)
        }
        print("colorInfos size/count: \(colorInfos.count)")
        colorInfos.forEach { c in
            if let matchedName = EPDColors.colorNames.first(where: { EPDColors.hexValue(for: $0) == c.hexValue }) {
                print("Matched color name: \(EPDColors.friendlyNames[matchedName] ?? "Unknown")")
            } else {
                print("No match found for color: \(c.hexValue)")
            }
        }
        let b64Buffers = ImageUtils.extractHMSBFromCanvas(image: image)
        serverUploader.uploadCanvas(b64Buffers: b64Buffers)
    }
}

struct ColorInfo: Identifiable {
    let id = UUID()
    let color: UIColor
    let hexValue: String
}

struct ImagePreview: View {
    let image: UIImage

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 300)
            Text("Image Size: \(Int(image.size.width)) x \(Int(image.size.height)) pixels")
                .foregroundColor(.gray)
        }
    }
}

struct UploadImageView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try? ModelContainer(for: Server.self, AppSettings.self, TextItem.self, CanvasItem.self, ImageItem.self, configurations: config)

        UploadImageView(image: UIImage(named: "example2")!, isPresented: .constant(true))
            .modelContainer(container!)
    }
}
