import SwiftUI
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// A model to hold all style settings for the app
class AppStyle: ObservableObject {
    // MARK: - Colors
    @Published var primaryColor: Color = Color(red: 0/255, green: 66/255, blue: 170/255)
    @Published var darkBackground: Color = Color(red: 34/255, green: 34/255, blue: 34/255)
    @Published var darkText: Color = Color(red: 76/255, green: 201/255, blue: 240/255)
    
    // MARK: - Sizing
    @Published var letterCellSize: CGFloat = 36
    @Published var guessLetterCellSize: CGFloat = 32
    @Published var letterSpacing: CGFloat = 4
    @Published var contentPadding: CGFloat = 16
    
    // MARK: - Font Sizes
    @Published var titleFontSize: CGFloat = 28
    @Published var bodyFontSize: CGFloat = 16
    @Published var captionFontSize: CGFloat = 12
    
    // MARK: - Preset themes
    static let defaultLight = AppStyle(isDark: false)
    static let defaultDark = AppStyle(isDark: true)
    
    init(isDark: Bool = true) {
        // Preset themes could be initialized here if needed
    }
    
    // Save the current style to UserDefaults
    func save() {
        // Convert colors to hex strings for storage
        let style: [String: Any] = [
            "primaryColor": primaryColor.toHex() ?? "#0042AA",
            "darkBackground": darkBackground.toHex() ?? "#222222",
            "darkText": darkText.toHex() ?? "#4cc9f0",
            "letterCellSize": letterCellSize,
            "guessLetterCellSize": guessLetterCellSize,
            "letterSpacing": letterSpacing,
            "contentPadding": contentPadding,
            "titleFontSize": titleFontSize,
            "bodyFontSize": bodyFontSize,
            "captionFontSize": captionFontSize
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: style) {
            UserDefaults.standard.set(data, forKey: "appStyle")
        }
    }
    
    // Load style from UserDefaults
    static func load() -> AppStyle? {
        guard let data = UserDefaults.standard.data(forKey: "appStyle"),
              let style = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        let appStyle = AppStyle()
        
        // Load colors
        if let hexColor = style["primaryColor"] as? String {
            appStyle.primaryColor = Color(hex: hexColor) ?? appStyle.primaryColor
        }
        if let hexColor = style["darkBackground"] as? String {
            appStyle.darkBackground = Color(hex: hexColor) ?? appStyle.darkBackground
        }
        if let hexColor = style["darkText"] as? String {
            appStyle.darkText = Color(hex: hexColor) ?? appStyle.darkText
        }
        
        // Load sizes
        if let size = style["letterCellSize"] as? CGFloat {
            appStyle.letterCellSize = size
        }
        if let size = style["guessLetterCellSize"] as? CGFloat {
            appStyle.guessLetterCellSize = size
        }
        if let spacing = style["letterSpacing"] as? CGFloat {
            appStyle.letterSpacing = spacing
        }
        if let padding = style["contentPadding"] as? CGFloat {
            appStyle.contentPadding = padding
        }
        
        // Load font sizes
        if let size = style["titleFontSize"] as? CGFloat {
            appStyle.titleFontSize = size
        }
        if let size = style["bodyFontSize"] as? CGFloat {
            appStyle.bodyFontSize = size
        }
        if let size = style["captionFontSize"] as? CGFloat {
            appStyle.captionFontSize = size
        }
        
        return appStyle
    }
    
    // Reset to default
    func resetToDefault(isDark: Bool) {
        let defaultStyle = isDark ? AppStyle.defaultDark : AppStyle.defaultLight
        
        // Copy all properties from default style
        self.primaryColor = defaultStyle.primaryColor
        self.darkBackground = defaultStyle.darkBackground
        self.darkText = defaultStyle.darkText
        self.letterCellSize = defaultStyle.letterCellSize
        self.guessLetterCellSize = defaultStyle.guessLetterCellSize
        self.letterSpacing = defaultStyle.letterSpacing
        self.contentPadding = defaultStyle.contentPadding
        self.titleFontSize = defaultStyle.titleFontSize
        self.bodyFontSize = defaultStyle.bodyFontSize
        self.captionFontSize = defaultStyle.captionFontSize
    }
}

// MARK: - Color Extensions for Hex Conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        #if os(iOS) || os(tvOS)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        #elseif os(macOS)
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        #endif
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
    
    struct StyleEditorView: View {
        @Environment(\.dismiss) private var dismiss
        @ObservedObject var appStyle: AppStyle
        @State private var selectedTab = 0
        @State private var showColorPicker = false
        @State private var colorToEdit: ColorField?
        
        // To hold temporary values
        @State private var tempColor: Color = .blue
        
        enum ColorField {
            case primary, darkBackground, darkText
        }
        
        var body: some View {
            NavigationView {
                VStack {
                    Picker("Style Category", selection: $selectedTab) {
                        Text("Colors").tag(0)
                        Text("Sizing").tag(1)
                        Text("Fonts").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    TabView(selection: $selectedTab) {
                        // MARK: - Colors Tab
                        colorsTab
                            .tag(0)
                        
                        // MARK: - Sizing Tab
                        sizingTab
                            .tag(1)
                        
                        // MARK: - Fonts Tab
                        fontsTab
                            .tag(2)
                    }
#if os(iOS) || os(tvOS)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
#elseif os(macOS)
                    .tabViewStyle(DefaultTabViewStyle())
#endif
                    
                    // Preview Area
                    VStack {
                        Text("Preview")
                            .font(.headline)
                            .padding(.top)
                        
                        previewArea
                            .frame(height: 200)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    // Action Buttons
                    HStack {
                        Button("Reset to Default") {
                            appStyle.resetToDefault(isDark: true)
                        }
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        Button("Save") {
                            appStyle.save()
                            dismiss()
                        }
                        .padding()
                        .background(appStyle.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
                .navigationTitle("Style Editor")
                .toolbar {
#if os(iOS) || os(tvOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
#elseif os(macOS)
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
#endif
                }
                .sheet(isPresented: $showColorPicker) {
                    VStack {
                        Text("Select Color")
                            .font(.headline)
                            .padding()
                        
                        ColorPicker("Color", selection: $tempColor)
                            .padding()
                        
                        HStack {
                            Button("Cancel") {
                                showColorPicker = false
                            }
                            .padding()
                            
                            Spacer()
                            
                            Button("Apply") {
                                applySelectedColor()
                                showColorPicker = false
                            }
                            .padding()
                            .background(appStyle.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                    .presentationDetents([.medium])
                }
            }
        }
        
        // MARK: - Colors Tab
        var colorsTab: some View {
            Form {
                Section(header: Text("Primary Colors")) {
                    colorRow(title: "Primary Color", color: appStyle.primaryColor) {
                        colorToEdit = .primary
                        tempColor = appStyle.primaryColor
                        showColorPicker = true
                    }
                    
                    colorRow(title: "Dark Background", color: appStyle.darkBackground) {
                        colorToEdit = .darkBackground
                        tempColor = appStyle.darkBackground
                        showColorPicker = true
                    }
                    
                    colorRow(title: "Dark Text", color: appStyle.darkText) {
                        colorToEdit = .darkText
                        tempColor = appStyle.darkText
                        showColorPicker = true
                    }
                }
            }
        }
        
        // MARK: - Sizing Tab
        var sizingTab: some View {
            Form {
                Section(header: Text("Cell Sizing")) {
                    VStack(alignment: .leading) {
                        Text("Letter Cell Size: \(Int(appStyle.letterCellSize))")
                        Slider(value: $appStyle.letterCellSize, in: 24...56, step: 2)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Guess Letter Cell Size: \(Int(appStyle.guessLetterCellSize))")
                        Slider(value: $appStyle.guessLetterCellSize, in: 20...48, step: 2)
                    }
                }
                
                Section(header: Text("Spacing & Padding")) {
                    VStack(alignment: .leading) {
                        Text("Letter Spacing: \(Int(appStyle.letterSpacing))")
                        Slider(value: $appStyle.letterSpacing, in: 1...12, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Content Padding: \(Int(appStyle.contentPadding))")
                        Slider(value: $appStyle.contentPadding, in: 4...32, step: 2)
                    }
                }
            }
        }
        
        // MARK: - Fonts Tab
        var fontsTab: some View {
            Form {
                Section(header: Text("Font Sizes")) {
                    VStack(alignment: .leading) {
                        Text("Title Font Size: \(Int(appStyle.titleFontSize))")
                        Slider(value: $appStyle.titleFontSize, in: 16...42, step: 2)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Body Font Size: \(Int(appStyle.bodyFontSize))")
                        Slider(value: $appStyle.bodyFontSize, in: 12...24, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Caption Font Size: \(Int(appStyle.captionFontSize))")
                        Slider(value: $appStyle.captionFontSize, in: 8...16, step: 1)
                    }
                }
            }
        }
        
        // Preview area to show how settings will look
        var previewArea: some View {
            VStack {
                // Background color simulation
                ZStack {
                    // Background
                    appStyle.darkBackground
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack(spacing: appStyle.letterSpacing) {
                        // Sample title text
                        Text("decodey")
                            .font(.system(size: appStyle.titleFontSize, design: .monospaced))
                            .foregroundColor(appStyle.darkText)
                            .padding(.bottom)
                        
                        // Sample letter cells
                        HStack(spacing: appStyle.letterSpacing) {
                            // Encrypted letter
                            Text("A")
                                .font(.system(size: appStyle.bodyFontSize, design: .monospaced))
                                .frame(width: appStyle.letterCellSize, height: appStyle.letterCellSize)
                                .background(appStyle.darkText)
                                .foregroundColor(appStyle.darkBackground)
                                .cornerRadius(6)
                            
                            // Normal letter
                            Text("B")
                                .font(.system(size: appStyle.bodyFontSize, design: .monospaced))
                                .frame(width: appStyle.letterCellSize, height: appStyle.letterCellSize)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(appStyle.darkText)
                                .cornerRadius(6)
                            
                            // Guess letter
                            Text("C")
                                .font(.system(size: appStyle.bodyFontSize, design: .monospaced))
                                .frame(width: appStyle.guessLetterCellSize, height: appStyle.guessLetterCellSize)
                                .background(appStyle.darkText.opacity(0.2))
                                .foregroundColor(appStyle.darkText)
                                .cornerRadius(6)
                        }
                        .padding(appStyle.contentPadding)
                        
                        // Sample caption text
                        Text("Tap a letter to select it")
                            .font(.system(size: appStyle.captionFontSize))
                            .foregroundColor(.gray)
                    }
                }
            }
            .cornerRadius(12)
        }
        
        // Helper for color row
        func colorRow(title: String, color: Color, action: @escaping () -> Void) -> some View {
            Button(action: action) {
                HStack {
                    Text(title)
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: 30, height: 30)
                }
            }
        }
        
        // Apply the selected color based on which field was being edited
        func applySelectedColor() {
            switch colorToEdit {
            case .primary:
                appStyle.primaryColor = tempColor
            case .darkBackground:
                appStyle.darkBackground = tempColor
            case .darkText:
                appStyle.darkText = tempColor
            case nil:
                break
            }
        }
    }
    
    struct StyleEditorView_Previews: PreviewProvider {
        static var previews: some View {
            StyleEditorView(appStyle: AppStyle())
        }
    }

