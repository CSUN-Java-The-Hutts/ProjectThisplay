//
//  AppIconView.swift
//  ThisPlay
//
import SwiftUI
import SwiftData

struct AppIconView: View {
    @Environment(\.modelContext) var modelContext
    @Query var appSettingsList: [AppSettings]

    
    let icons: [String: String] = [
        "Default": "AppIcon",  // Use nil for the default icon
        "Mixed 1": "AppIcon_Mixed_1",
        "Mixed 2": "AppIcon_Mixed_2",
        "Mixed 3": "AppIcon_Mixed_3",
        "Peets 1": "AppIcon_Peets_1",
        "Shapes 1": "AppIcon_Shapes_1",
        "Shapes 2": "AppIcon_Shapes_2"
    ]

    var body: some View {
        let appSettings = appSettingsList.first ?? AppSettings()
        List(icons.keys.sorted(), id: \.self) { key in
            Button(action: {
                let iconName = icons[key] == "AppIcon" ? nil : icons[key]
                UIApplication.shared.setAlternateIconName(iconName) { error in
                    if let error = error {
                        print("App icon failed to change due to \(error.localizedDescription)")
                    } else {
                        print("App icon changed successfully.")
                        appSettings.customAppIcon = iconName
                        try? modelContext.save()
                    }
                }
            }) {
                HStack {
                    Image(uiImage: UIImage(named: icons[key]!) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .cornerRadius(8)
                    
                    Text(key)
                        .padding(.leading, 8)
                }
            }
        }
        .navigationTitle("Choose App Icon")
    }
}

