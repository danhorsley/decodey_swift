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
    
    var body: some View {
        ZStack {
            // Background
            (isDarkMode ? darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
                
            // Matrix rain effect (only visible when in dark mode and game is won)
            if isDarkMode && showMatrixRain {
                MatrixRainView(active: true, color: darkText)
            }
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    Button(action: {
                        // About button action
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(isDarkMode ? darkText : primaryColor)
                            .font(.title2)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("decodey")
                        .font(.custom("Courier", size: 28).bold())
                        .foregroundColor(isDarkMode ? darkText : primaryColor)
                    
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? darkText : primaryColor)
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Display encrypted and current text - always stacked vertically
                VStack(spacing: 8) {
                    // First text area (encrypted)
                    ZStack(alignment: .topLeading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                            .frame(maxWidth: .infinity)
                            
                        // Text content
                        VStack(alignment: .leading) {
                            Text("Encrypted:")
                                .font(.caption)
                                .foregroundColor(isDarkMode ? .gray : .gray)
                                .padding(.top, 8)
                                .padding(.leading, 8)
                            
                            Text(game.encrypted)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(isDarkMode ? .gray : .gray)
                                .padding(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Second text area (solution)
                    ZStack(alignment: .topLeading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                            .frame(maxWidth: .infinity)
                            
                        // Text content
                        VStack(alignment: .leading) {
                            Text("Your solution:")
                                .font(.caption)
                                .foregroundColor(isDarkMode ? darkText : primaryColor)
                                .padding(.top, 8)
                                .padding(.leading, 8)
                            
                            Text(game.currentDisplay)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(isDarkMode ? darkText : primaryColor)
                                .padding(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // Game status
                HStack {
                    Text("Mistakes: \(game.mistakes)/\(game.maxMistakes)")
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                    
                    Spacer()
                    
                    // Game reset button
                    if game.hasWon || game.hasLost {
                        Button(action: {
                            resetGame()
                        }) {
                            Label("New Game", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDarkMode ? darkText : primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Game Dashboard
                GameDashboardView(
                    game: $game,
                    showWinMessage: $showWinMessage,
                    showLoseMessage: $showLoseMessage,
                    isDarkMode: $isDarkMode,
                    primaryColor: primaryColor,
                    darkText: darkText
                )
                .padding(.top, 8)
                
                Spacer()
            }
            
            // Win message overlay
            if showWinMessage {
                winOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: showWinMessage)
                    .onAppear {
                        // Show matrix rain when win overlay appears
                        DispatchQueue.main.async {
                            withAnimation {
                                showMatrixRain = true
                            }
                        }
                    }
            }
            
            // Lose message overlay
            if showLoseMessage {
                loseOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: showLoseMessage)
            }
        }
    }
    
    // Reset game function
    private func resetGame() {
        game = Game()
        showWinMessage = false
        showLoseMessage = false
        showMatrixRain = false
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
                resetGame()
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
                resetGame()
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
