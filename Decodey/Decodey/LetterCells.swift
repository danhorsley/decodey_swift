import SwiftUI

// Cell for encrypted letters
// Cell for encrypted letters - updated to use style properties
struct EncryptedLetterCell: View {
    let letter: Character
    let isSelected: Bool
    let isGuessed: Bool
    let frequency: Int
    let action: () -> Void
    let isDarkMode: Bool
    let primaryColor: Color
    let darkText: Color
    let cellSize: CGFloat
    let fontSize: CGFloat
    let fontFamily: String
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                // Background and content
                Text(String(letter))
                    .font(.system(size: fontSize,
                           design: fontFamily == "System" ? .default : .monospaced))
                    .fontWeight(.bold)
                    .frame(width: cellSize, height: cellSize)
                    .background(
                        backgroundForState()
                    )
                    .foregroundColor(
                        foregroundForState()
                    )
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? (isDarkMode ? darkText : primaryColor) : Color.clear, lineWidth: 2)
                    )
                
                // Frequency counter in bottom right
                if frequency > 0 && !isGuessed {
                    Text("\(frequency)")
                        .font(.system(size: fontSize * 0.6))
                        .foregroundColor(foregroundForState().opacity(0.7))
                        .offset(x: -4, y: -2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isGuessed)
    }
    
    // Background color based on state
    private func backgroundForState() -> Color {
        if isGuessed {
            return isDarkMode ? Color(white: 0.2) : Color(white: 0.85)
        } else if isSelected {
            return isDarkMode ? darkText : primaryColor
        } else {
            return isDarkMode ? Color(red: 0/255, green: 45/255, blue: 100/255) : Color(red: 30/255, green: 90/255, blue: 200/255)
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

// Cell for guessing letters - updated to use style properties
struct GuessLetterCell: View {
    let letter: Character
    let isUsed: Bool
    let action: () -> Void
    let isDarkMode: Bool
    let primaryColor: Color
    let darkText: Color
    let cellSize: CGFloat
    let fontSize: CGFloat
    let fontFamily: String
    
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(size: fontSize,
                       design: fontFamily == "System" ? .default : .monospaced))
                .fontWeight(.bold)
                .frame(width: cellSize, height: cellSize)
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

struct GameGridsView_Previews: PreviewProvider {
    static var previews: some View {
        GameGridsView(
            game: .constant(Game()),
            isDarkMode: .constant(true),
            primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
            darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
            letterCellSize: 36,
            guessLetterCellSize: 32,
            letterSpacing: 4,
            fontFamily: "System",
            fontSize: 16,
            showTextHelpers: true,
            onWin: {},
            onLose: {}
        )
        .frame(height: 400)
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
        .previewLayout(.sizeThatFits)
    }
}
// Preview provider for SwiftUI canvas
struct LetterCells_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Encrypted letter cells
            Text("Encrypted Letters")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                // Normal state
                EncryptedLetterCell(
                    letter: "A",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 3,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 36,
                    fontSize: 16,
                    fontFamily: "System"
                )
                
                // Selected state
                EncryptedLetterCell(
                    letter: "B",
                    isSelected: true,
                    isGuessed: false,
                    frequency: 2,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 36,
                    fontSize: 16,
                    fontFamily: "System"
                )
                
                // Guessed state
                EncryptedLetterCell(
                    letter: "C",
                    isSelected: false,
                    isGuessed: true,
                    frequency: 1,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 36,
                    fontSize: 16,
                    fontFamily: "System"
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
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 32,
                    fontSize: 16,
                    fontFamily: "System"
                )
                
                // Used state
                GuessLetterCell(
                    letter: "Y",
                    isUsed: true,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 32,
                    fontSize: 16,
                    fontFamily: "System"
                )
                
                // Available state with monospace font
                GuessLetterCell(
                    letter: "Z",
                    isUsed: false,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 32,
                    fontSize: 16,
                    fontFamily: "Menlo"
                )
            }
            
            // Different size previews
            Text("Size Variations")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            HStack(spacing: 12) {
                // Small cells
                EncryptedLetterCell(
                    letter: "S",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 2,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 28,
                    fontSize: 14,
                    fontFamily: "System"
                )
                
                // Medium cells (default)
                EncryptedLetterCell(
                    letter: "M",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 3,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 36,
                    fontSize: 16,
                    fontFamily: "System"
                )
                
                // Large cells
                EncryptedLetterCell(
                    letter: "L",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 1,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    cellSize: 48,
                    fontSize: 20,
                    fontFamily: "System"
                )
            }
        }
        .padding()
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
        .previewLayout(.sizeThatFits)
    }
}
