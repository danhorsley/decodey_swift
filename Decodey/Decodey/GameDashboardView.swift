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
