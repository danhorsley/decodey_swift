import SwiftUI

// Cell for encrypted letters
struct EncryptedLetterCell: View {
    let letter: Character
    let isSelected: Bool
    let isGuessed: Bool
    let frequency: Int
    let action: () -> Void
    let isDarkMode: Bool
    let primaryColor: Color
    let darkText: Color
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background and content
                Text(String(letter))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 40, height: 40)
                    .background(
                        backgroundForState()
                    )
                    .foregroundColor(
                        foregroundForState()
                    )
                    .cornerRadius(8)
                
                // Frequency counter in bottom right
                if frequency > 0 && !isGuessed {
                    Text("\(frequency)")
                        .font(.system(size: 10))
                        .foregroundColor(isDarkMode ? .gray : .gray)
                        .padding(2)
                        .offset(x: 12, y: 12)
                }
            }
        }
        .disabled(isGuessed)
    }
    
    // Background color based on state
    private func backgroundForState() -> Color {
        if isGuessed {
            return isDarkMode ? Color(white: 0.2) : Color(white: 0.9)
        } else if isSelected {
            return isDarkMode ? darkText : primaryColor
        } else {
            return isDarkMode ? Color(white: 0.15) : Color(white: 0.95)
        }
    }
    
    // Foreground (text) color based on state
    private func foregroundForState() -> Color {
        if isGuessed {
            return .gray
        } else if isSelected {
            return isDarkMode ? .black : .white
        } else {
            return isDarkMode ? .white : .black
        }
    }
}

// Cell for guessing letters
struct GuessLetterCell: View {
    let letter: Character
    let isUsed: Bool
    let action: () -> Void
    let isDarkMode: Bool
    let primaryColor: Color
    let darkText: Color
    
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 36, height: 36)
                .background(
                    isUsed
                        ? (isDarkMode ? Color(white: 0.2) : Color(white: 0.9))
                        : (isDarkMode ? Color(darkText.opacity(0.2)) : Color(primaryColor.opacity(0.1)))
                )
                .foregroundColor(
                    isUsed
                        ? .gray
                        : (isDarkMode ? darkText : primaryColor)
                )
                .cornerRadius(8)
        }
        .disabled(isUsed)
    }
}//
//  LetterCells.swift
//  Decodey
//
//  Created by Daniel Horsley on 05/05/2025.
//

