import SwiftUI

struct SimpleSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: UserSettings
    @Binding var isDarkMode: Bool
    
    // Local state for settings before saving
    @State private var localIsDarkMode: Bool
    @State private var localShowHelpers: Bool
    
    // Initialize with the current settings
    init(settings: UserSettings, isDarkMode: Binding<Bool>) {
        self.settings = settings
        self._isDarkMode = isDarkMode
        self._localIsDarkMode = State(initialValue: settings.isDarkMode)
        self._localShowHelpers = State(initialValue: settings.showTextHelpers)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $localIsDarkMode)
                        .onChange(of: localIsDarkMode) { _, newValue in
                            // Preview the theme changes immediately
                            isDarkMode = newValue
                        }
                }
                
                Section(header: Text("Game Interface"), footer: Text("Text helpers provide instructions and labels in the game interface. You may want to disable them after you're familiar with the game.")) {
                    Toggle("Show Text Helpers", isOn: $localShowHelpers)
                }
                
                Section {
                    Button("Save Settings") {
                        saveSettings()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Revert to original settings if canceled
                        isDarkMode = settings.isDarkMode
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        // Save the settings to the model and user defaults
        settings.isDarkMode = localIsDarkMode
        settings.showTextHelpers = localShowHelpers
    }
}
