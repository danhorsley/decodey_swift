import SwiftUI

@main
struct DecodeyApp: App {
    // Create a shared AppStyle instance that will be available throughout the app
    @StateObject private var appStyle = AppStyle.load() ?? AppStyle()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appStyle)
        }
    }
}
