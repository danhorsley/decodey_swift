import SwiftUI
import SpriteKit

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Utility functions for color conversion
func convertToSKColor(color: Color) -> SKColor {
    #if os(iOS) || os(tvOS)
    let uiColor = UIColor(color)
    return SKColor(red: CGFloat(CIColor(color: uiColor).red),
                  green: CGFloat(CIColor(color: uiColor).green),
                   blue: CGFloat(CIColor(color: uiColor).blue),
                  alpha: CGFloat(CIColor(color: uiColor).alpha))
    #elseif os(macOS)
    let nsColor = NSColor(color)
    return SKColor(red: nsColor.redComponent,
                 green: nsColor.greenComponent,
                  blue: nsColor.blueComponent,
                 alpha: nsColor.alphaComponent)
    #else
    // Fallback for other platforms
    return SKColor.white
    #endif
}//
//  ColorUtils.swift
//  Decodey
//
//  Created by Daniel Horsley on 06/05/2025.
//

