import SwiftUI

@main
struct DecodeyApp: App {
    // Use standard system environment values instead of custom styles
    @StateObject private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(userSettings.isDarkMode ? .dark : .light)
                .accentColor(.blue) // System accent color
        }
    }
}
