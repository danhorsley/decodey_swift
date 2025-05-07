import SwiftUI
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// An enhanced model to hold all style settings for the app
class AppStyle: ObservableObject {
    // MARK: - Colors
    @Published var primaryColor: Color = Color(red: 0/255, green: 66/255, blue: 170/255)
    @Published var darkBackground: Color = Color(red: 34/255, green: 34/255, blue: 34/255)
    @Published var darkText: Color = Color(red: 76/255, green: 201/255, blue: 240/255)
    
    // MARK: - Letter Cell Colors
    @Published var letterCellNormalColor: Color = Color(red: 0/255, green: 45/255, blue: 100/255)
    @Published var letterCellSelectedColor: Color = Color(red: 76/255, green: 201/255, blue: 240/255)
    @Published var letterCellGuessedColor: Color = Color(white: 0.2)
    
    // MARK: - Sizing
    @Published var letterCellSize: CGFloat = 36
    @Published var guessLetterCellSize: CGFloat = 32
    @Published var letterSpacing: CGFloat = 4
    @Published var letterCellPadding: CGFloat = 0 // New: Letter cell padding
    @Published var contentPadding: CGFloat = 16
    @Published var gridMargin: CGFloat = 20 // New: Left/right margin of grids
    
    // MARK: - Vertical Positioning
    @Published var hintButtonTopPadding: CGFloat = 10 // New: Space above hint button
    @Published var hintButtonBottomPadding: CGFloat = 10 // New: Space below hint button
    
    // MARK: - Text Spacing
    @Published var textDisplaySpacing: CGFloat = 12 // New: Gap between encrypted and display text
    @Published var textToGridSpacing: CGFloat = 20 // New: Gap between text and grids
    
    // MARK: - Font Settings
    @Published var fontFamily: String = "System"
    @Published var titleFontSize: CGFloat = 28
    @Published var bodyFontSize: CGFloat = 16
    @Published var letterCellFontSize: CGFloat = 18 // New: Letter cell font size
    @Published var captionFontSize: CGFloat = 12
    
    // MARK: - Text Layout
    @Published var textLineSpacing: CGFloat = 4
    @Published var textLetterSpacing: CGFloat = 2
    
    // MARK: - Use Dynamic or Hardcoded Styling
    @Published var useDynamicStyling: Bool = true
    
    // MARK: - Device Specific Adjustments
    @Published var smallDeviceAdjustment: CGFloat = 0.85
    @Published var largeDeviceAdjustment: CGFloat = 1.15
    
    // MARK: - Alignment
    @Published var textAlignment: TextAlignment = .center // Always center for text blocks
    
    // MARK: - Preset themes
    static let defaultLight = AppStyle(isDark: false)
    static let defaultDark = AppStyle(isDark: true)
    
    init(isDark: Bool = true) {
        // Initialize with default values
        // If hardcoded values exist, load them here
        loadHardcodedStyleIfNeeded()
    }
    
    // Save the current style to UserDefaults
    func save() {
        // Convert colors to hex strings for storage
        let style: [String: Any] = [
            // Colors
            "primaryColor": primaryColor.toHex() ?? "#0042AA",
            "darkBackground": darkBackground.toHex() ?? "#222222",
            "darkText": darkText.toHex() ?? "#4cc9f0",
            
            // Letter Cell Colors
            "letterCellNormalColor": letterCellNormalColor.toHex() ?? "#002D64",
            "letterCellSelectedColor": letterCellSelectedColor.toHex() ?? "#4cc9f0",
            "letterCellGuessedColor": letterCellGuessedColor.toHex() ?? "#333333",
            
            // Sizing
            "letterCellSize": letterCellSize,
            "guessLetterCellSize": guessLetterCellSize,
            "letterSpacing": letterSpacing,
            "letterCellPadding": letterCellPadding,
            "contentPadding": contentPadding,
            "gridMargin": gridMargin,
            
            // Vertical Positioning
            "hintButtonTopPadding": hintButtonTopPadding,
            "hintButtonBottomPadding": hintButtonBottomPadding,
            
            // Text Spacing
            "textDisplaySpacing": textDisplaySpacing,
            "textToGridSpacing": textToGridSpacing,
            
            // Font settings
            "fontFamily": fontFamily,
            "titleFontSize": titleFontSize,
            "bodyFontSize": bodyFontSize,
            "letterCellFontSize": letterCellFontSize,
            "captionFontSize": captionFontSize,
            
            // Text layout
            "textLineSpacing": textLineSpacing,
            "textLetterSpacing": textLetterSpacing,
            
            // Style mode
            "useDynamicStyling": useDynamicStyling,
            
            // Device adjustments
            "smallDeviceAdjustment": smallDeviceAdjustment,
            "largeDeviceAdjustment": largeDeviceAdjustment
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
        
        // Load letter cell colors
        if let hexColor = style["letterCellNormalColor"] as? String {
            appStyle.letterCellNormalColor = Color(hex: hexColor) ?? appStyle.letterCellNormalColor
        }
        if let hexColor = style["letterCellSelectedColor"] as? String {
            appStyle.letterCellSelectedColor = Color(hex: hexColor) ?? appStyle.letterCellSelectedColor
        }
        if let hexColor = style["letterCellGuessedColor"] as? String {
            appStyle.letterCellGuessedColor = Color(hex: hexColor) ?? appStyle.letterCellGuessedColor
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
        if let padding = style["letterCellPadding"] as? CGFloat {
            appStyle.letterCellPadding = padding
        }
        if let padding = style["contentPadding"] as? CGFloat {
            appStyle.contentPadding = padding
        }
        if let margin = style["gridMargin"] as? CGFloat {
            appStyle.gridMargin = margin
        }
        
        // Load vertical positioning
        if let padding = style["hintButtonTopPadding"] as? CGFloat {
            appStyle.hintButtonTopPadding = padding
        }
        if let padding = style["hintButtonBottomPadding"] as? CGFloat {
            appStyle.hintButtonBottomPadding = padding
        }
        
        // Load text spacing
        if let spacing = style["textDisplaySpacing"] as? CGFloat {
            appStyle.textDisplaySpacing = spacing
        }
        if let spacing = style["textToGridSpacing"] as? CGFloat {
            appStyle.textToGridSpacing = spacing
        }
        
        // Load font settings
        if let family = style["fontFamily"] as? String {
            appStyle.fontFamily = family
        }
        if let size = style["titleFontSize"] as? CGFloat {
            appStyle.titleFontSize = size
        }
        if let size = style["bodyFontSize"] as? CGFloat {
            appStyle.bodyFontSize = size
        }
        if let size = style["letterCellFontSize"] as? CGFloat {
            appStyle.letterCellFontSize = size
        }
        if let size = style["captionFontSize"] as? CGFloat {
            appStyle.captionFontSize = size
        }
        
        // Load text layout
        if let spacing = style["textLineSpacing"] as? CGFloat {
            appStyle.textLineSpacing = spacing
        }
        if let spacing = style["textLetterSpacing"] as? CGFloat {
            appStyle.textLetterSpacing = spacing
        }
        
        // Load style mode
        if let useDynamic = style["useDynamicStyling"] as? Bool {
            appStyle.useDynamicStyling = useDynamic
        }
        
        // Load device adjustments
        if let adjustment = style["smallDeviceAdjustment"] as? CGFloat {
            appStyle.smallDeviceAdjustment = adjustment
        }
        if let adjustment = style["largeDeviceAdjustment"] as? CGFloat {
            appStyle.largeDeviceAdjustment = adjustment
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
        self.letterCellNormalColor = defaultStyle.letterCellNormalColor
        self.letterCellSelectedColor = defaultStyle.letterCellSelectedColor
        self.letterCellGuessedColor = defaultStyle.letterCellGuessedColor
        self.letterCellSize = defaultStyle.letterCellSize
        self.guessLetterCellSize = defaultStyle.guessLetterCellSize
        self.letterSpacing = defaultStyle.letterSpacing
        self.letterCellPadding = defaultStyle.letterCellPadding
        self.contentPadding = defaultStyle.contentPadding
        self.gridMargin = defaultStyle.gridMargin
        self.hintButtonTopPadding = defaultStyle.hintButtonTopPadding
        self.hintButtonBottomPadding = defaultStyle.hintButtonBottomPadding
        self.textDisplaySpacing = defaultStyle.textDisplaySpacing
        self.textToGridSpacing = defaultStyle.textToGridSpacing
        self.fontFamily = defaultStyle.fontFamily
        self.titleFontSize = defaultStyle.titleFontSize
        self.bodyFontSize = defaultStyle.bodyFontSize
        self.letterCellFontSize = defaultStyle.letterCellFontSize
        self.captionFontSize = defaultStyle.captionFontSize
        self.textLineSpacing = defaultStyle.textLineSpacing
        self.textLetterSpacing = defaultStyle.textLetterSpacing
        self.useDynamicStyling = defaultStyle.useDynamicStyling
        self.smallDeviceAdjustment = defaultStyle.smallDeviceAdjustment
        self.largeDeviceAdjustment = defaultStyle.largeDeviceAdjustment
    }
    
    // Creates a snapshot file for hardcoding
    func createStyleSnapshot() -> String {
        var snapshot = "// Decodey Style Snapshot\n"
        snapshot += "// Generated: \(Date().formatted())\n\n"
        
        snapshot += "struct HardcodedStyle {\n"
        
        // Colors section
        snapshot += "    // MARK: - Colors\n"
        snapshot += "    static let primaryColor = Color(red: \(primaryColor.components.red)/255, green: \(primaryColor.components.green)/255, blue: \(primaryColor.components.blue)/255)\n"
        snapshot += "    static let darkBackground = Color(red: \(darkBackground.components.red)/255, green: \(darkBackground.components.green)/255, blue: \(darkBackground.components.blue)/255)\n"
        snapshot += "    static let darkText = Color(red: \(darkText.components.red)/255, green: \(darkText.components.green)/255, blue: \(darkText.components.blue)/255)\n\n"
        
        // Letter Cell Colors
        snapshot += "    // MARK: - Letter Cell Colors\n"
        snapshot += "    static let letterCellNormalColor = Color(red: \(letterCellNormalColor.components.red)/255, green: \(letterCellNormalColor.components.green)/255, blue: \(letterCellNormalColor.components.blue)/255)\n"
        snapshot += "    static let letterCellSelectedColor = Color(red: \(letterCellSelectedColor.components.red)/255, green: \(letterCellSelectedColor.components.green)/255, blue: \(letterCellSelectedColor.components.blue)/255)\n"
        snapshot += "    static let letterCellGuessedColor = Color(red: \(letterCellGuessedColor.components.red)/255, green: \(letterCellGuessedColor.components.green)/255, blue: \(letterCellGuessedColor.components.blue)/255)\n\n"
        
        // Sizing section
        snapshot += "    // MARK: - Sizing\n"
        snapshot += "    static let letterCellSize: CGFloat = \(letterCellSize)\n"
        snapshot += "    static let guessLetterCellSize: CGFloat = \(guessLetterCellSize)\n"
        snapshot += "    static let letterSpacing: CGFloat = \(letterSpacing)\n"
        snapshot += "    static let letterCellPadding: CGFloat = \(letterCellPadding)\n"
        snapshot += "    static let contentPadding: CGFloat = \(contentPadding)\n"
        snapshot += "    static let gridMargin: CGFloat = \(gridMargin)\n\n"
        
        // Vertical positioning
        snapshot += "    // MARK: - Vertical Positioning\n"
        snapshot += "    static let hintButtonTopPadding: CGFloat = \(hintButtonTopPadding)\n"
        snapshot += "    static let hintButtonBottomPadding: CGFloat = \(hintButtonBottomPadding)\n\n"
        
        // Text spacing
        snapshot += "    // MARK: - Text Spacing\n"
        snapshot += "    static let textDisplaySpacing: CGFloat = \(textDisplaySpacing)\n"
        snapshot += "    static let textToGridSpacing: CGFloat = \(textToGridSpacing)\n\n"
        
        // Font settings
        snapshot += "    // MARK: - Font Settings\n"
        snapshot += "    static let fontFamily = \"\(fontFamily)\"\n"
        snapshot += "    static let titleFontSize: CGFloat = \(titleFontSize)\n"
        snapshot += "    static let bodyFontSize: CGFloat = \(bodyFontSize)\n"
        snapshot += "    static let letterCellFontSize: CGFloat = \(letterCellFontSize)\n"
        snapshot += "    static let captionFontSize: CGFloat = \(captionFontSize)\n\n"
        
        // Text layout
        snapshot += "    // MARK: - Text Layout\n"
        snapshot += "    static let textLineSpacing: CGFloat = \(textLineSpacing)\n"
        snapshot += "    static let textLetterSpacing: CGFloat = \(textLetterSpacing)\n\n"
        
        // Device adjustments
        snapshot += "    // MARK: - Device Adjustments\n"
        snapshot += "    static let smallDeviceAdjustment: CGFloat = \(smallDeviceAdjustment)\n"
        snapshot += "    static let largeDeviceAdjustment: CGFloat = \(largeDeviceAdjustment)\n"
        
        snapshot += "}\n"
        
        return snapshot
    }
    
    // Save snapshot to a file
    func saveStyleSnapshotToFile() -> Bool {
        let snapshot = createStyleSnapshot()
        
        // Get document directory
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmm"
        let fileName = "DecodeyStyleSnapshot_\(dateFormatter.string(from: Date()))"
        let fileURL = documentDirectory.appendingPathComponent("\(fileName).swift")
        
        do {
            try snapshot.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Style snapshot saved to: \(fileURL.path)")
            return true
        } catch {
            print("Failed to save style snapshot: \(error)")
            return false
        }
    }
    
    // Load hardcoded style if not using dynamic styling
    private func loadHardcodedStyleIfNeeded() {
        // This would contain the hardcoded style values that would be generated
        // from a snapshot file
    }
}

// MARK: - Color components accessor
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        #if os(iOS) || os(tvOS)
        let uiColor = UIColor(self)
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r * 255, g * 255, b * 255, a)
        #elseif os(macOS)
        let nsColor = NSColor(self)
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r * 255, g * 255, b * 255, a)
        #else
        return (0, 0, 0, 0)
        #endif
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

struct EnhancedStyleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appStyle: AppStyle
    @State private var selectedTab = 0
    @State private var showColorPicker = false
    @State private var colorToEdit: ColorField?
    @State private var showSnapshotSavedAlert = false
    @State private var saveSuccess = false
    
    // Available font families - Fixed to ensure they all work
    let availableFonts = ["System", "Courier"]
    
    // To hold temporary values
    @State private var tempColor: Color = .blue
    
    enum ColorField {
        case primary, darkBackground, darkText
        case letterCellNormal, letterCellSelected, letterCellGuessed
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Top tabs
                Picker("Style Category", selection: $selectedTab) {
                    Text("Colors").tag(0)
                    Text("Cells").tag(1)
                    Text("Layout").tag(2)
                    Text("Fonts").tag(3)
                    Text("Advanced").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    // MARK: - Colors Tab
                    colorsTab
                        .tag(0)
                    
                    // MARK: - Cell Styling Tab
                    cellStylingTab
                        .tag(1)
                    
                    // MARK: - Layout Tab
                    layoutTab
                        .tag(2)
                    
                    // MARK: - Fonts Tab
                    fontsTab
                        .tag(3)
                    
                    // MARK: - Advanced Tab
                    advancedTab
                        .tag(4)
                }
                #if os(iOS) || os(tvOS)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                #endif
                
                // Preview Area
                VStack {
                    Text("Preview")
                        .font(.headline)
                        .padding(.top)
                    
                    previewArea
                        .frame(height: 250)
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
                    
                    Button("Snapshot") {
                        saveSuccess = appStyle.saveStyleSnapshotToFile()
                        showSnapshotSavedAlert = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
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
            .navigationTitle("Enhanced Style Editor")
            .toolbar {
                #if os(iOS) || os(tvOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                #else
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
                #if os(iOS) || os(tvOS)
                .presentationDetents([.medium])
                #endif
            }
            .alert(isPresented: $showSnapshotSavedAlert) {
                Alert(
                    title: Text(saveSuccess ? "Snapshot Saved" : "Save Failed"),
                    message: Text(saveSuccess ? "Style snapshot has been saved to Documents folder." : "Failed to save style snapshot."),
                    dismissButton: .default(Text("OK"))
                )
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
            
            Section(header: Text("Color Information"), footer: Text("These colors are used throughout the app for various components. The primary color is used for buttons and selected states, while dark text is used in dark mode for text elements.")) {
                Text("RGB Values:")
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Primary: R:\(Int(appStyle.primaryColor.components.red)) G:\(Int(appStyle.primaryColor.components.green)) B:\(Int(appStyle.primaryColor.components.blue))")
                    Text("Background: R:\(Int(appStyle.darkBackground.components.red)) G:\(Int(appStyle.darkBackground.components.green)) B:\(Int(appStyle.darkBackground.components.blue))")
                    Text("Dark Text: R:\(Int(appStyle.darkText.components.red)) G:\(Int(appStyle.darkText.components.green)) B:\(Int(appStyle.darkText.components.blue))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Cell Styling Tab
    var cellStylingTab: some View {
        Form {
            Section(header: Text("Letter Cell Colors")) {
                colorRow(title: "Normal Cell", color: appStyle.letterCellNormalColor) {
                    colorToEdit = .letterCellNormal
                    tempColor = appStyle.letterCellNormalColor
                    showColorPicker = true
                }
                
                colorRow(title: "Selected Cell", color: appStyle.letterCellSelectedColor) {
                    colorToEdit = .letterCellSelected
                    tempColor = appStyle.letterCellSelectedColor
                    showColorPicker = true
                }
                
                colorRow(title: "Guessed Cell", color: appStyle.letterCellGuessedColor) {
                    colorToEdit = .letterCellGuessed
                    tempColor = appStyle.letterCellGuessedColor
                    showColorPicker = true
                }
            }
            
            Section(header: Text("Cell Sizing")) {
                VStack(alignment: .leading) {
                    Text("Letter Cell Size: \(Int(appStyle.letterCellSize))")
                    Slider(value: $appStyle.letterCellSize, in: 24...56, step: 2)
                }
                
                VStack(alignment: .leading) {
                    Text("Guess Letter Cell Size: \(Int(appStyle.guessLetterCellSize))")
                    Slider(value: $appStyle.guessLetterCellSize, in: 20...48, step: 2)
                }
                
                VStack(alignment: .leading) {
                    Text("Letter Cell Padding: \(Int(appStyle.letterCellPadding))")
                    Slider(value: $appStyle.letterCellPadding, in: 0...10, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Letter Spacing: \(Int(appStyle.letterSpacing))")
                    Slider(value: $appStyle.letterSpacing, in: 1...12, step: 1)
                }
            }
            
            Section(header: Text("Cell Demonstration")) {
                HStack(spacing: appStyle.letterSpacing) {
                    // Normal state
                    LetterCellPreview(
                        letter: "A",
                        state: .normal,
                        isDarkMode: true,
                        style: appStyle
                    )
                    
                    // Selected state
                    LetterCellPreview(
                        letter: "B",
                        state: .selected,
                        isDarkMode: true,
                        style: appStyle
                    )
                    
                    // Guessed state
                    LetterCellPreview(
                        letter: "C",
                        state: .guessed,
                        isDarkMode: true,
                        style: appStyle
                    )
                }
                .padding()
                .background(appStyle.darkBackground)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Layout Tab
    var layoutTab: some View {
        Form {
            Section(header: Text("Spacing & Padding")) {
                VStack(alignment: .leading) {
                    Text("Content Padding: \(Int(appStyle.contentPadding))")
                    Slider(value: $appStyle.contentPadding, in: 4...32, step: 2)
                }
                
                VStack(alignment: .leading) {
                    Text("Grid Margin: \(Int(appStyle.gridMargin))")
                    Slider(value: $appStyle.gridMargin, in: 0...40, step: 2)
                }
            }
            
            Section(header: Text("Text Display Spacing")) {
                VStack(alignment: .leading) {
                    Text("Between Encrypted & Display: \(Int(appStyle.textDisplaySpacing))")
                    Slider(value: $appStyle.textDisplaySpacing, in: 4...24, step: 2)
                }
                
                VStack(alignment: .leading) {
                    Text("Between Text & Grids: \(Int(appStyle.textToGridSpacing))")
                    Slider(value: $appStyle.textToGridSpacing, in: 8...36, step: 2)
                }
            }
            
            Section(header: Text("Hint Button Position")) {
                VStack(alignment: .leading) {
                    Text("Space Above Hint Button: \(Int(appStyle.hintButtonTopPadding))")
                    Slider(value: $appStyle.hintButtonTopPadding, in: 0...30, step: 2)
                }
                
                VStack(alignment: .leading) {
                    Text("Space Below Hint Button: \(Int(appStyle.hintButtonBottomPadding))")
                    Slider(value: $appStyle.hintButtonBottomPadding, in: 0...30, step: 2)
                }
            }
            
            Section(header: Text("Text Layout")) {
                VStack(alignment: .leading) {
                    Text("Text Line Spacing: \(Int(appStyle.textLineSpacing))")
                    Slider(value: $appStyle.textLineSpacing, in: 0...12, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Text Letter Spacing: \(appStyle.textLetterSpacing, specifier: "%.1f")")
                    Slider(value: $appStyle.textLetterSpacing, in: 0...5, step: 0.5)
                }
            }
            
            Section(header: Text("Layout Preview")) {
                Text("Text alignment is always centered for better readability.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("This is a multi-line\ntext display example\nfor the game")
                    .lineSpacing(appStyle.textLineSpacing)
                    .tracking(appStyle.textLetterSpacing)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Fonts Tab
    var fontsTab: some View {
        Form {
            Section(header: Text("Font Family")) {
                Picker("Font", selection: $appStyle.fontFamily) {
                    ForEach(availableFonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
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
                    Text("Letter Cell Font Size: \(Int(appStyle.letterCellFontSize))")
                    Slider(value: $appStyle.letterCellFontSize, in: 12...30, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Caption Font Size: \(Int(appStyle.captionFontSize))")
                    Slider(value: $appStyle.captionFontSize, in: 8...16, step: 1)
                }
            }
            
            Section(header: Text("Font Preview")) {
                Text("Title")
                    .font(.system(size: appStyle.titleFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .padding(.bottom, 4)
                
                Text("Body Text")
                    .font(.system(size: appStyle.bodyFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .padding(.bottom, 4)
                
                Text("Cell Text")
                    .font(.system(size: appStyle.letterCellFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .padding(.bottom, 4)
                
                Text("Caption/Helper")
                    .font(.system(size: appStyle.captionFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
            }
            
            Section(header: Text("Font Note"), footer: Text("Only System and Courier fonts are fully supported in the current version.")) {
                Text("Monospaced fonts generally work better for cryptography games as they help maintain alignment between letters.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Advanced Tab
    var advancedTab: some View {
        Form {
            Section(header: Text("Styling Mode")) {
                Toggle("Use Dynamic Styling", isOn: $appStyle.useDynamicStyling)
                
                if !appStyle.useDynamicStyling {
                    Text("Using hardcoded styles. These will not change unless you toggle back to dynamic styling.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Device Adjustments")) {
                VStack(alignment: .leading) {
                    Text("Small Device Adjustment: \(appStyle.smallDeviceAdjustment, specifier: "%.2f")")
                    Slider(value: $appStyle.smallDeviceAdjustment, in: 0.5...1.0, step: 0.05)
                }
                
                VStack(alignment: .leading) {
                    Text("Large Device Adjustment: \(appStyle.largeDeviceAdjustment, specifier: "%.2f")")
                    Slider(value: $appStyle.largeDeviceAdjustment, in: 1.0...1.5, step: 0.05)
                }
                
                Text("These values are multipliers applied to element sizes based on the device size. Values less than 1.0 make elements smaller, while values greater than 1.0 make elements larger.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Snapshot")) {
                Button("Save Style Snapshot") {
                    saveSuccess = appStyle.saveStyleSnapshotToFile()
                    showSnapshotSavedAlert = true
                }
                
                Text("Saves the current style configuration to a Swift file in your Documents folder. Use this file to hardcode styles in the app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                        .font(.system(size: appStyle.titleFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                        .foregroundColor(appStyle.darkText)
                        .padding(.bottom)
                    
                    // Sample encrypted text
                    Text("ZKHQH QRU BFWLRQ.")
                        .font(.system(size: appStyle.bodyFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                        .tracking(appStyle.textLetterSpacing)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, appStyle.contentPadding)
                    
                    // Space between encrypted and display
                    Spacer()
                        .frame(height: appStyle.textDisplaySpacing)
                    
                    // Sample solution text
                    Text("W█E█E ███ ███I██.")
                        .font(.system(size: appStyle.bodyFontSize, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                        .tracking(appStyle.textLetterSpacing)
                        .multilineTextAlignment(.center)
                        .foregroundColor(appStyle.darkText)
                        .padding(.horizontal, appStyle.contentPadding)
                    
                    // Space before grids
                    Spacer()
                        .frame(height: appStyle.textToGridSpacing)
                    
                    // Layout with grids and hint button
                    HStack(spacing: 0) {
                        // Encrypted grid
                        HStack(spacing: appStyle.letterSpacing) {
                            // Sample encrypted letters
                            LetterCellPreview(
                                letter: "Z",
                                state: .normal,
                                isDarkMode: true,
                                style: appStyle
                            )
                            
                            LetterCellPreview(
                                letter: "K",
                                state: .selected,
                                isDarkMode: true,
                                style: appStyle
                            )
                            
                            LetterCellPreview(
                                letter: "F",
                                state: .guessed,
                                isDarkMode: true,
                                style: appStyle
                            )
                        }
                        .padding(.leading, appStyle.gridMargin)
                        
                        Spacer()
                        
                        // Hint button placeholder
                        VStack {
                            Spacer()
                                .frame(height: appStyle.hintButtonTopPadding)
                            
                            Text("HINT")
                                .font(.system(size: appStyle.captionFontSize))
                                .foregroundColor(appStyle.darkText)
                                .frame(width: 60, height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(appStyle.darkText, lineWidth: 1)
                                )
                            
                            Spacer()
                                .frame(height: appStyle.hintButtonBottomPadding)
                        }
                        
                        Spacer()
                        
                        // Guess grid
                        HStack(spacing: appStyle.letterSpacing) {
                            // Sample guess letters
                            GuessLetterCellPreview(
                                letter: "W",
                                isUsed: false,
                                isDarkMode: true,
                                style: appStyle
                            )
                            
                            GuessLetterCellPreview(
                                letter: "H",
                                isUsed: true,
                                isDarkMode: true,
                                style: appStyle
                            )
                            
                            GuessLetterCellPreview(
                                letter: "E",
                                isUsed: false,
                                isDarkMode: true,
                                style: appStyle
                            )
                        }
                        .padding(.trailing, appStyle.gridMargin)
                    }
                }
                .padding(.vertical)
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
        case .letterCellNormal:
            appStyle.letterCellNormalColor = tempColor
        case .letterCellSelected:
            appStyle.letterCellSelectedColor = tempColor
        case .letterCellGuessed:
            appStyle.letterCellGuessedColor = tempColor
        case nil:
            break
        }
    }
}

// Letter Cell states for preview
enum LetterCellState {
    case normal, selected, guessed
}

// Letter Cell Preview
struct LetterCellPreview: View {
    let letter: String
    let state: LetterCellState
    let isDarkMode: Bool
    let style: AppStyle
    
    var body: some View {
        Text(letter)
            .font(.system(size: style.letterCellFontSize, design: style.fontFamily == "System" ? .default : .monospaced))
            .fontWeight(.bold)
            .frame(width: style.letterCellSize, height: style.letterCellSize)
            .padding(style.letterCellPadding)
            .background(backgroundForState())
            .foregroundColor(foregroundForState())
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(state == .selected ? (isDarkMode ? style.darkText : style.primaryColor) : Color.clear, lineWidth: 2)
            )
    }
    
    // Background color based on state
    private func backgroundForState() -> Color {
        switch state {
        case .normal:
            return isDarkMode ? style.letterCellNormalColor : style.letterCellNormalColor.opacity(0.8)
        case .selected:
            return isDarkMode ? style.letterCellSelectedColor : style.primaryColor
        case .guessed:
            return isDarkMode ? style.letterCellGuessedColor : Color(white: 0.85)
        }
    }
    
    // Foreground (text) color based on state
    private func foregroundForState() -> Color {
        switch state {
        case .normal:
            return .white
        case .selected:
            return isDarkMode ? style.darkBackground : .white
        case .guessed:
            return .gray
        }
    }
}

// Guess Letter Cell Preview
struct GuessLetterCellPreview: View {
    let letter: String
    let isUsed: Bool
    let isDarkMode: Bool
    let style: AppStyle
    
    var body: some View {
        Text(letter)
            .font(.system(size: style.letterCellFontSize, design: style.fontFamily == "System" ? .default : .monospaced))
            .fontWeight(.bold)
            .frame(width: style.guessLetterCellSize, height: style.guessLetterCellSize)
            .padding(style.letterCellPadding)
            .background(
                isUsed ? (isDarkMode ? Color(white: 0.2) : Color(white: 0.85)) :
                        (isDarkMode ? Color(white: 0.15) : Color.white)
            )
            .foregroundColor(
                isUsed ? .gray : (isDarkMode ? .white : .black)
            )
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct EnhancedStyleEditorView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedStyleEditorView(appStyle: AppStyle())
            .preferredColorScheme(.dark)
    }
}
