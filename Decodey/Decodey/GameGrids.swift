import SwiftUI

struct GameGridsView: View {
    @Binding var game: Game
    @Binding var isDarkMode: Bool
    
    // Style reference
    @EnvironmentObject var appStyle: AppStyle
    
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
                        .padding(.leading, appStyle.gridMargin)
                    
                    // Hint button in the center
                    VStack {
                        Spacer()
                            .frame(height: appStyle.hintButtonTopPadding)
                        
                        hintButton
                        
                        Spacer()
                            .frame(height: appStyle.hintButtonBottomPadding)
                    }
                    .frame(width: 130)
                    
                    guessGrid
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, appStyle.gridMargin)
                }
            } else {
                // Portrait layout
                VStack(spacing: appStyle.letterSpacing * 5) {
                    encryptedGrid
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack {
                        Spacer()
                            .frame(height: appStyle.hintButtonTopPadding)
                        
                        hintButton
                        
                        Spacer()
                            .frame(height: appStyle.hintButtonBottomPadding)
                    }
                    
                    guessGrid
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    // Encrypted letters grid (left side)
    private var encryptedGrid: some View {
        VStack(alignment: .center, spacing: appStyle.letterSpacing * 2) {
            if showTextHelpers {
                Text("Select a letter to decode:")
                    .font(.system(size: appStyle.captionFontSize,
                           design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: appStyle.letterSpacing), count: 5)
            
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
                        appStyle: appStyle
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = game.uniqueEncryptedLetters().count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: appStyle.letterCellSize, height: appStyle.letterCellSize)
                }
            }
            .frame(maxWidth: 220 + (appStyle.letterCellSize - 36)) // Adjust max width based on cell size
        }
    }
    
    // Guess letters grid (right side)
    private var guessGrid: some View {
        VStack(alignment: .center, spacing: appStyle.letterSpacing * 2) {
            if showTextHelpers {
                Text("Guess with:")
                    .font(.system(size: appStyle.captionFontSize,
                           design: appStyle.fontFamily == "System" ? .default : .monospaced))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: appStyle.letterSpacing), count: 5)
            
            // Get alphabet letters
            let uniqueLetters = Array(Set(game.solution.filter { $0.isLetter })).sorted()
            
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
                                        onWin()
                                    } else if game.hasLost {
                                        onLose()
                                    }
                                }
                            }
                        },
                        isDarkMode: isDarkMode,
                        appStyle: appStyle
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = uniqueLetters.count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: appStyle.guessLetterCellSize, height: appStyle.guessLetterCellSize)
                }
            }
            .frame(maxWidth: 220 + (appStyle.guessLetterCellSize - 32)) // Adjust max width based on cell size
        }
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
                        .progressViewStyle(CircularProgressViewStyle(tint: isDarkMode ? appStyle.darkText : appStyle.primaryColor))
                        .padding(8)
                } else {
                    // Show remaining hints
                    Text("\(game.maxMistakes - game.mistakes)")
                        .font(.system(.title, design: appStyle.fontFamily == "System" ? .default : .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                }
                
                // Only show hint tokens text if text helpers are enabled
                if showTextHelpers {
                    Text("HINT TOKENS")
                        .font(.system(size: appStyle.captionFontSize,
                               design: appStyle.fontFamily == "System" ? .default : .monospaced))
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
            return isDarkMode ? appStyle.darkText : appStyle.primaryColor
        }
    }
}

struct GameGridsView_Previews: PreviewProvider {
    static var previews: some View {
        let appStyle = AppStyle()
        
        GameGridsView(
            game: .constant(Game()),
            isDarkMode: .constant(true),
            showTextHelpers: true,
            onWin: {},
            onLose: {}
        )
        .environmentObject(appStyle)
        .frame(height: 400)
        .background(Color(red: 34/255, green: 34/255, blue: 34/255))
        .previewLayout(.sizeThatFits)
    }
}
