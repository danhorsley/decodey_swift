import SwiftUI

struct ContentView: View {
    @State private var game = Game()
    @State private var showWinMessage = false
    @State private var showLoseMessage = false
    @State private var showMatrixRain = false
    
    // Theme colors
    let primaryColor = Color(red: 0/255, green: 66/255, blue: 170/255) // #0042AA
    let darkBackground = Color(red: 34/255, green: 34/255, blue: 34/255) // #222222
    let darkText = Color(red: 76/255, green: 201/255, blue: 240/255) // #4cc9f0
    
    // Layout settings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isDarkMode = true
    
    var gridColumns: [GridItem] {
        let columns = horizontalSizeClass == .compact ? 5 : 6
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: columns)
    }
    
    var body: some View {
        ZStack {
            // Background
            (isDarkMode ? darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
                
            // Matrix rain effect (only visible when in dark mode and game is won)
            if isDarkMode && showWinMessage {
                MatrixRainView(active: true, color: darkText)
            }
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        // About button action
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(isDarkMode ? darkText : primaryColor)
                            .font(.title2)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Text("decodey")
                        .font(.custom("Courier", size: 28).bold())
                        .foregroundColor(isDarkMode ? darkText : primaryColor)
                    
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(isDarkMode ? darkText : primaryColor)
                            .font(.title2)
                    }
                    .padding()
                }
                
                // Display encrypted and current text
                VStack(spacing: 8) {
                    Text(game.encrypted)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(isDarkMode ? .gray : .gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                        .cornerRadius(8)
                    
                    Text(game.currentDisplay)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(isDarkMode ? darkText : primaryColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Game status
                HStack {
                    Text("Mistakes: \(game.mistakes)/\(game.maxMistakes)")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Spacer()
                    
                    Button(action: {
                        // Get a hint - implement this later
                    }) {
                        Text("HINT")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isDarkMode ? darkText : primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Encrypted letters grid (letters to decode)
                VStack(alignment: .leading) {
                    Text("Select a letter to decode:")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.bottom, 4)
                    
                    LazyVGrid(columns: gridColumns, spacing: 8) {
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
                .padding(.horizontal)
                
                // Original letters grid (guessing)
                VStack(alignment: .leading) {
                    Text("Guess with:")
                        .font(.subheadline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(.bottom, 4)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(game.originalLetters, id: \.self) { letter in
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
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Win message overlay
            if showWinMessage {
                winOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5))
            }
            
            // Lose message overlay
            if showLoseMessage {
                loseOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5))
            }
        }
    }
    
    // Win message overlay
    var winOverlay: some View {
        VStack {
            Text("You Win!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? darkText : primaryColor)
            
            Text(game.solution)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding()
            
            Button(action: {
                // Reset the game
                game = Game()
                showWinMessage = false
            }) {
                Text("Play Again")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isDarkMode ? darkText : primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
    }
    
    // Lose message overlay
    var loseOverlay: some View {
        VStack {
            Text("Game Over")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("The solution was:")
                .foregroundColor(.white)
                .padding(.top)
            
            Text(game.solution)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding()
            
            Button(action: {
                // Reset the game
                game = Game()
                showLoseMessage = false
            }) {
                Text("Try Again")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
