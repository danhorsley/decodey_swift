import SwiftUI

struct GameDashboardView: View {
    @Binding var game: Game
    @Binding var showWinMessage: Bool
    @Binding var showLoseMessage: Bool
    @Binding var isDarkMode: Bool
    
    // Theme colors
    let primaryColor: Color
    let darkText: Color
    
    // Hint animation
    @State private var isHintInProgress = false
    
    // Access the app style
    @EnvironmentObject var appStyle: AppStyle
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 0) {
                if !isLandscape {
                    // Portrait mode layout - vertical stacking
                    encryptedLetterGrid
                        .padding(.bottom, appStyle.letterSpacing * 2)
                    
                    hintButton
                        .padding(.bottom, appStyle.letterSpacing * 2)
                    
                    guessLetterGrid
                } else {
                    // Landscape mode layout - horizontal arrangement
                    HStack(alignment: .center, spacing: 0) {
                        encryptedLetterGrid
                            .frame(maxWidth: .infinity)
                        
                        hintButton
                            .padding(.horizontal, appStyle.contentPadding)
                        
                        guessLetterGrid
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, appStyle.letterSpacing * 2)
        }
    }
    
    private var encryptedLetterGrid: some View {
        VStack(alignment: .leading, spacing: appStyle.letterSpacing) {
            Text("Select a letter to decode:")
                .font(.system(size: appStyle.captionFontSize))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, 4)
            
            // Dynamic columns based on available letters
            let columns = Array(repeating: GridItem(.flexible(), spacing: appStyle.letterSpacing / 2), count: 5)
            
            LazyVGrid(columns: columns, spacing: appStyle.letterSpacing) {
                ForEach(game.uniqueEncryptedLetters(), id: \.self) { letter in
                    EncryptedLetterCell(
                        letter: letter,
                        isSelected: game.selectedLetter == letter,
                        isGuessed: game.correctlyGuessed().contains(letter),
                        frequency: game.letterFrequency[letter] ?? 0,
                        cellSize: appStyle.letterCellSize,
                        fontSize: appStyle.bodyFontSize,
                        action: {
                            withAnimation {
                                game.selectLetter(letter)
                            }
                        },
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                        darkText: darkText
                    )
                }
            }
        }
    }
    
    private var guessLetterGrid: some View {
        VStack(alignment: .leading, spacing: appStyle.letterSpacing) {
            Text("Guess with:")
                .font(.system(size: appStyle.captionFontSize))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.bottom, 4)
            
            // Get unique letters from the solution
            let uniqueLetters = Array(Set(game.solution.filter { $0.isLetter })).sorted()
            
            // Calculate optimal number of columns based on available letters
            let columnCount = min(7, max(5, uniqueLetters.count / 3))
            let columns = Array(repeating: GridItem(.flexible(), spacing: appStyle.letterSpacing / 2), count: columnCount)
            
            LazyVGrid(columns: columns, spacing: appStyle.letterSpacing) {
                ForEach(uniqueLetters, id: \.self) { letter in
                    GuessLetterCell(
                        letter: letter,
                        isUsed: game.guessedMappings.values.contains(letter),
                        cellSize: appStyle.guessLetterCellSize,
                        fontSize: appStyle.bodyFontSize,
                        action: {
                            if game.selectedLetter != nil {
                                withAnimation {
                                    let _ = game.makeGuess(letter)
                                    
                                    // Check game status
                                    if game.hasWon {
                                        showWinMessage = true
                                    } else if game.hasLost {
                                        showLoseMessage = true
                                    }
                                }
                            }
                        },
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                        darkText: darkText
                    )
                }
            }
        }
    }
    
    private var hintButton: some View {
        Button(action: {
            // Only perform action if not already in progress
            guard !isHintInProgress else { return }
            
            // Process hint immediately
            let _ = game.getHint()
            
            // Check game status after hint
            if game.hasWon {
                showWinMessage = true
            } else if game.hasLost {
                showLoseMessage = true
            }
        }) {
            VStack {
                // Show spinner when hint is in progress
                if isHintInProgress {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: isDarkMode ? darkText : primaryColor))
                        .padding(8)
                } else {
                    // Show remaining hints
                    Text("\(game.maxMistakes - game.mistakes)")
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? darkText : primaryColor)
                }
                
                Text("HINT TOKENS")
                    .font(.system(size: appStyle.captionFontSize))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .opacity(0.7)
            }
            .frame(width: 80, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(statusColor)
            )
            .background(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
            .cornerRadius(8)
        }
        .disabled(isHintInProgress || game.hasWon || game.hasLost)
    }
    
    // Dynamic color based on remaining mistakes
    private var statusColor: Color {
        let remainingMistakes = game.maxMistakes - game.mistakes
        
        if remainingMistakes <= 1 {
            return .red
        } else if remainingMistakes <= game.maxMistakes / 2 {
            return .orange
        } else {
            return isDarkMode ? darkText : primaryColor
        }
    }
}

// Updated letter cells that use the app style parameters
struct EncryptedLetterCell: View {
    let letter: Character
    let isSelected: Bool
    let isGuessed: Bool
    let frequency: Int
    let cellSize: CGFloat
    let fontSize: CGFloat
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
                    .font(.system(size: fontSize, design: .monospaced))
                    .fontWeight(.bold)
                    .frame(width: cellSize, height: cellSize)
                    .background(
                        backgroundForState()
                    )
                    .foregroundColor(
                        foregroundForState()
                    )
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? (isDarkMode ? darkText : primaryColor) : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                
                // Frequency counter in bottom right
                if frequency > 0 && !isGuessed {
                    Text("\(frequency)")
                        .font(.system(size: fontSize * 0.6))
                        .foregroundColor(isDarkMode ? .gray : .gray)
                        .padding(2)
                        .offset(x: cellSize * 0.3, y: cellSize * 0.3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    let cellSize: CGFloat
    let fontSize: CGFloat
    let action: () -> Void
    let isDarkMode: Bool
    let primaryColor: Color
    let darkText: Color
    
    @State private var isPressed = false
    @State private var isPreviouslyGuessed = false
    
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.system(size: fontSize, design: .monospaced))
                .fontWeight(.bold)
                .frame(width: cellSize, height: cellSize)
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
struct GameDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        GameDashboardView(
            game: .constant(Game()),
            showWinMessage: .constant(false),
            showLoseMessage: .constant(false),
            isDarkMode: .constant(true),
            primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
            darkText: Color(red: 76/255, green: 201/255, blue: 240/255)
        )
        .environmentObject(AppStyle())
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
    }
}
