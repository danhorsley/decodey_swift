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
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background and content
                Text(String(letter))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: 36, height: 36)  // Smaller, more compact cells
                    .background(
                        backgroundForState()
                    )
                    .foregroundColor(
                        foregroundForState()
                    )
                    .cornerRadius(6)  // Slightly smaller corner radius for compact look
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? (isDarkMode ? darkText : primaryColor) : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)  // Scale effect for press feedback
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                // Frequency counter in bottom right
                if frequency > 0 && !isGuessed {
                    Text("\(frequency)")
                        .font(.system(size: 10))
                        .foregroundColor(isDarkMode ? .gray : .gray)
                        .padding(2)
                        .offset(x: 10, y: 10)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())  // Use PlainButtonStyle to prevent default button styling
        .disabled(isGuessed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            self.isPressed = pressing
        }, perform: {})
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
            return isDarkMode ? Color(white: 0.15) : .white
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
    
    @State private var isPressed = false
    @State private var isPreviouslyGuessed = false
    
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: 32, height: 32)  // Slightly smaller cells for guess grid
                .background(
                    backgroundForState()
                )
                .foregroundColor(
                    foregroundForState()
                )
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isUsed ? Color.clear : (isDarkMode ? darkText.opacity(0.3) : primaryColor.opacity(0.3)), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                .overlay(
                    // Add a line through previously guessed letters
                    isPreviouslyGuessed ?
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.red.opacity(0.7))
                        .rotationEffect(Angle(degrees: -45))
                    : nil
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isUsed || isPreviouslyGuessed)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            self.isPressed = pressing
        }, perform: {})
    }
    
    // Background color based on state
    private func backgroundForState() -> Color {
        if isUsed {
            return isDarkMode ? Color(white: 0.2) : Color(white: 0.9)
        } else if isPreviouslyGuessed {
            return isDarkMode ? Color.red.opacity(0.2) : Color.red.opacity(0.1)
        } else {
            return isDarkMode ? Color(darkText.opacity(0.1)) : Color(primaryColor.opacity(0.1))
        }
    }
    
    // Foreground (text) color based on state
    private func foregroundForState() -> Color {
        if isUsed {
            return .gray
        } else if isPreviouslyGuessed {
            return isDarkMode ? .red.opacity(0.7) : .red.opacity(0.7)
        } else {
            return isDarkMode ? darkText : primaryColor
        }
    }
}

// Preview provider for SwiftUI canvas
struct LetterCells_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                EncryptedLetterCell(
                    letter: "A",
                    isSelected: false,
                    isGuessed: false,
                    frequency: 3,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
                
                EncryptedLetterCell(
                    letter: "B",
                    isSelected: true,
                    isGuessed: false,
                    frequency: 2,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
                
                EncryptedLetterCell(
                    letter: "C",
                    isSelected: false,
                    isGuessed: true,
                    frequency: 1,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
            }
            
            HStack(spacing: 8) {
                GuessLetterCell(
                    letter: "X",
                    isUsed: false,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
                
                GuessLetterCell(
                    letter: "Y",
                    isUsed: true,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
                
                GuessLetterCell(
                    letter: "Z",
                    isUsed: false,
                    action: {},
                    isDarkMode: true,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
                )
            }
        }
        .padding()
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
        .previewLayout(.sizeThatFits)
    }
}
