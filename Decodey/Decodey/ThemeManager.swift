import SwiftUI

class ThemeManager: ObservableObject {
    @Published var textSize: TextSize = .medium
    @Published var useHighContrastMode: Bool = false
    
    enum TextSize: String, CaseIterable, Identifiable {
        case small, medium, large, extraLarge
        
        var id: String { self.rawValue }
        
        var scaleFactor: CGFloat {
            switch self {
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.2
            case .extraLarge: return 1.4
            }
        }
    }
    
    // Save and load methods
    func save() {
        UserDefaults.standard.set(textSize.rawValue, forKey: "textSize")
        UserDefaults.standard.set(useHighContrastMode, forKey: "highContrastMode")
    }
    
    static func load() -> ThemeManager {
        let manager = ThemeManager()
        
        if let savedSize = UserDefaults.standard.string(forKey: "textSize"),
           let size = TextSize(rawValue: savedSize) {
            manager.textSize = size
        }
        
        manager.useHighContrastMode = UserDefaults.standard.bool(forKey: "highContrastMode")
        
        return manager
    }
}//
//  ThemeManager.swift
//  Decodey
//
//  Created by Daniel Horsley on 07/05/2025.
//

