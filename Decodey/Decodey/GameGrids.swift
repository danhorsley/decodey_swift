import SwiftUI

struct GameGridsView: View {
    @Binding var game: Game
    @Binding var isDarkMode: Bool
    
    // Style properties passed from ContentView
    var primaryColor: Color
    var darkText: Color
    var letterCellSize: CGFloat
    var guessLetterCellSize: CGFloat
    var letterSpacing: CGFloat
    var fontFamily: String
    var fontSize: CGFloat
    
    let showTextHelpers: Bool
    let onWin: () -> Void
    let onLose: () -> Void
    
    @State private var isHintInProgress = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape layout
                HStack(alignment: .top, spacing: 0) {
                    encryptedGrid
                        .frame(maxWidth: .infinity)
                    
                    // Hint button in the center
                    VStack {
                        Spacer()
                        hintButton
                        Spacer()
                    }
                    .frame(width: 130)
                    
                    guessGrid
                        .frame(maxWidth: .infinity)
                }
            } else {
                // Portrait layout
                VStack(spacing: letterSpacing * 5) {
                    encryptedGrid
                    hintButton
                    guessGrid
                }
            }
        }
    }
    
    // Encrypted letters grid (left side)
    private var encryptedGrid: some View {
        VStack(alignment: .center, spacing: letterSpacing * 2) {
            if showTextHelpers {
                Text("Select a letter to decode:")
                    .font(.system(size: fontSize * 0.75,
                           design: fontFamily == "System" ? .default : .monospaced))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: letterSpacing), count: 5)
            
            LazyVGrid(columns: columns, spacing: letterSpacing) {
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
                        darkText: darkText,
                        cellSize: letterCellSize,
                        fontSize: fontSize,
                        fontFamily: fontFamily
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = game.uniqueEncryptedLetters().count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: letterCellSize, height: letterCellSize)
                }
            }
            .frame(maxWidth: 220 + (letterCellSize - 36)) // Adjust max width based on cell size
        }
        .padding(.horizontal, 8)
    }
    
    // Guess letters grid (right side)
    private var guessGrid: some View {
        VStack(alignment: .center, spacing: letterSpacing * 2) {
            if showTextHelpers {
                Text("Guess with:")
                    .font(.system(size: fontSize * 0.75,
                           design: fontFamily == "System" ? .default : .monospaced))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: letterSpacing), count: 5)
            
            // Get alphabet letters
            let uniqueLetters = Array(Set(game.solution.filter { $0.isLetter })).sorted()
            
            LazyVGrid(columns: columns, spacing: letterSpacing) {
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
                                        onWin()
                                    } else if game.hasLost {
                                        onLose()
                                    }
                                }
                            }
                        },
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                        darkText: darkText,
                        cellSize: guessLetterCellSize,
                        fontSize: fontSize,
                        fontFamily: fontFamily
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = uniqueLetters.count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: guessLetterCellSize, height: guessLetterCellSize)
                }
            }
            .frame(maxWidth: 220 + (guessLetterCellSize - 32)) // Adjust max width based on cell size
        }
        .padding(.horizontal, 8)
    }
    
    // Hint button
    private var hintButton: some View {
        Button(action: {
            // Only perform action if not already in progress
            guard !isHintInProgress else { return }
            
            // Show loading state
            isHintInProgress = true
            
            // Add a slight delay to show the loading state (can remove in production)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Process hint
                let _ = game.getHint()
                
                // Reset loading state
                isHintInProgress = false
                
                // Check game status after hint
                if game.hasWon {
                    onWin()
                } else if game.hasLost {
                    onLose()
                }
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
                        .font(.system(.title, design: fontFamily == "System" ? .default : .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? darkText : primaryColor)
                }
                
                // Only show hint tokens text if text helpers are enabled
                if showTextHelpers {
                    Text("HINT TOKENS")
                        .font(.system(size: fontSize * 0.6,
                               design: fontFamily == "System" ? .default : .monospaced))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .opacity(0.7)
                }
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


