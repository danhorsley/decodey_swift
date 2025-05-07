import SwiftUI

struct GameDashboardView: View {
    @Binding var game: Game
    @Binding var showWinMessage: Bool
    @Binding var showLoseMessage: Bool
    
    // Use environment values instead of AppStyle
    @Environment(\.colorScheme) var colorScheme
    
    // Text helpers setting
    let showTextHelpers: Bool
    
    // Hint animation
    @State private var isHintInProgress = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 0) {
                if !isLandscape {
                    // Portrait mode layout - vertical stacking
                    encryptedLetterGrid
                        .padding(.bottom, 8)
                    
                    hintButton
                        .padding(.vertical, 10)
                    
                    guessLetterGrid
                } else {
                    // Landscape mode layout - horizontal arrangement
                    HStack(alignment: .center, spacing: 0) {
                        encryptedLetterGrid
                            .frame(maxWidth: .infinity)
                            .padding(.leading, 20)
                        
                        hintButton
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        guessLetterGrid
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 20)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var encryptedLetterGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Only show helper text if enabled
            if showTextHelpers {
                Text("Select a letter to decode:")
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.bottom, 4)
            }
            
            // Dynamic columns based on available letters
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 5)
            
            LazyVGrid(columns: columns, spacing: 4) {
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
                        }
                    )
                }
            }
        }
    }
    
    private var guessLetterGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Only show helper text if enabled
            if showTextHelpers {
                Text("Guess with:")
                    .font(.system(size: 12))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.bottom, 4)
            }
            
            // Get unique letters from the solution
            let uniqueLetters = Array(Set(game.solution.filter { $0.isLetter })).sorted()
            
            // Calculate optimal number of columns based on available letters
            let columnCount = min(7, max(5, uniqueLetters.count / 3))
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: columnCount)
            
            LazyVGrid(columns: columns, spacing: 4) {
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
                        }
                    )
                }
            }
        }
    }
    
    private var hintButton: some View {
        HintButtonView(
            remainingHints: game.maxMistakes - game.mistakes,
            isLoading: isHintInProgress,
            isDarkMode: colorScheme == .dark,
            onHintRequested: {
                // Only perform action if not already in progress
                guard !isHintInProgress else { return }
                
                // Set loading state
                isHintInProgress = true
                
                // Process hint after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let _ = game.getHint()
                    
                    // Reset loading state
                    isHintInProgress = false
                    
                    // Check game status after hint
                    if game.hasWon {
                        showWinMessage = true
                    } else if game.hasLost {
                        showLoseMessage = true
                    }
                }
            }
        )
    }
}

struct GameDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        GameDashboardView(
            game: .constant(Game()),
            showWinMessage: .constant(false),
            showLoseMessage: .constant(false),
            showTextHelpers: true
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
    }
}
