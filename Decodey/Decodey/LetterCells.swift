import SwiftUI

// Cell for encrypted letters - updated to use all style properties
struct EncryptedLetterCell: View {
    let letter: Character
    let isSelected: Bool
    let isGuessed: Bool
    let frequency: Int
    let action: () -> Void
    let isDarkMode: Bool
    let appStyle: AppStyle
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                // Background and content
                Text(String(letter))
                    .font(.system(size: appStyle.letterCellFontSize,
                           design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .fontWeight(.bold)
                    .frame(width: appStyle.letterCellSize, height: appStyle.letterCellSize)
                    .padding(appStyle.letterCellPadding)
                    .background(
                        backgroundForState()
                    )
                    .foregroundColor(
                        foregroundForState()
                    )
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? (isDarkMode ? appStyle.darkText : appStyle.primaryColor) : Color.clear, lineWidth: 2)
                    )
                
                // Frequency counter in bottom right
                if frequency > 0 && !isGuessed {
                    Text("\(frequency)")
                        .font(.system(size: appStyle.letterCellFontSize * 0.6))
                        .foregroundColor(foregroundForState().opacity(0.7))
                        .offset(x: -4, y: -2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isGuessed)
    }
    
    // Background color based on state using style colors
    private func backgroundForState() -> Color {
        if isGuessed {
            return isDarkMode ? appStyle.letterCellGuessedColor : Color(white: 0.85)
        } else if isSelected {
            return isDarkMode ? appStyle.letterCellSelectedColor : appStyle.primaryColor
        } else {
            return isDarkMode ? appStyle.letterCellNormalColor : Color(red: 30/255, green: 90/255, blue: 200/255)
        }
    }
    
    // Foreground (text) color based on state
    private func foregroundForState() -> Color {
        if isGuessed {
            return .gray
        } else if isSelected {
            return isDarkMode ? Color(white: 0.15) : .white
        } else {
            return .white
        }
    }
}

// Cell for guessing letters - updated to use all style properties
struct GuessLetterCell: View {
    let letter: Character
    let isUsed: Bool
    let action: () -> Void
    let isDarkMode: Bool
    let appStyle: AppStyle
    
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(size: appStyle.letterCellFontSize,
                       design: appStyle.fontFamily == "System" ? .default : .monospaced))
                .fontWeight(.bold)
                .frame(width: appStyle.guessLetterCellSize, height: appStyle.guessLetterCellSize)
                .padding(appStyle.letterCellPadding)
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
        .buttonStyle(PlainButtonStyle())
        .disabled(isUsed)
    }
}

struct LetterCells_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Encrypted letter cells
            Text("Encrypted Letters")
                .font(.headline)
                .foregroundColor(.white)
            
            let appStyle = AppStyle()
            
            HStack(spacing: 8) {
                // Normal state
                EncryptedLetterCell(
                    letter: "A",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 3,
                    action: {},
                    isDarkMode: true,
                    appStyle: appStyle
                )
                
                // Selected state
                EncryptedLetterCell(
                    letter: "B",
                    isSelected: true,
                    isGuessed: false,
                    frequency: 2,
                    action: {},
                    isDarkMode: true,
                    appStyle: appStyle
                )
                
                // Guessed state
                EncryptedLetterCell(
                    letter: "C",
                    isSelected: false,
                    isGuessed: true,
                    frequency: 1,
                    action: {},
                    isDarkMode: true,
                    appStyle: appStyle
                )
            }
            
            // Guess letter cells
            Text("Guess Letters")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            HStack(spacing: 8) {
                // Available state
                GuessLetterCell(
                    letter: "X",
                    isUsed: false,
                    action: {},
                    isDarkMode: true,
                    appStyle: appStyle
                )
                
                // Used state
                GuessLetterCell(
                    letter: "Y",
                    isUsed: true,
                    action: {},
                    isDarkMode: true,
                    appStyle: appStyle
                )
            }
        }
        .padding()
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
        .previewLayout(.sizeThatFits)
    }
}
