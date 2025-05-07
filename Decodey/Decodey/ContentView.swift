import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var game = Game()
    @State private var showWinMessage = false
    @State private var showLoseMessage = false
    @State private var showMatrixRain = false
    @State private var showMenuSheet = false
    @State private var showAboutSheet = false
    @State private var showSettingsSheet = false
    
    // Use system environment values rather than custom styles
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    // User settings
    @StateObject private var userSettings = UserSettings()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background using system colors
                Color(colorScheme == .dark ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                // Matrix rain effect (only visible when game is won)
                if showMatrixRain {
                    MatrixRainEffect(
                        active: showMatrixRain,
                        color: colorScheme == .dark ?
                               SKColor(red: 0, green: 0.8, blue: 0.4, alpha: 1) :
                               SKColor(red: 0, green: 0.6, blue: 0.9, alpha: 1)
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                
                VStack(spacing: 16) {
                    // Game content
                    displayTextArea
                    
                    // Game dashboard with grids and hint button
                    GameGridsView(
                        game: $game,
                        showWinMessage: $showWinMessage,
                        showLoseMessage: $showLoseMessage,
                        showTextHelpers: userSettings.showTextHelpers
                    )
                    
                    Spacer()
                }
                .padding()
                
                // Win message overlay
                if showWinMessage {
                    winMessageOverlay
                }
                
                // Lose message overlay
                if showLoseMessage {
                    loseMessageOverlay
                }
            }
            .navigationTitle("Decodey")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: { showMenuSheet = true }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
            .sheet(isPresented: $showSettingsSheet) {
                SimpleSettingsView(settings: userSettings, isDarkMode: $userSettings.isDarkMode)
            }
            .sheet(isPresented: $showMenuSheet) {
                MenuView(
                    showAbout: $showAboutSheet,
                    onNewGame: resetGame
                )
            }
            .onAppear {
                // Try to load saved game
                if let savedGame = Game.loadSavedGame() {
                    self.game = savedGame
                    
                    // Check if the loaded game was already complete
                    if game.hasWon {
                        showWinMessage = true
                    } else if game.hasLost {
                        showLoseMessage = true
                    }
                }
            }
        }
        .preferredColorScheme(userSettings.isDarkMode ? .dark : .light)
        .dynamicTypeSize(userSettings.useAccessibilityTextSize ? .accessibility3 : .large)
    }
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Display area for the encrypted and solution text
    private var displayTextArea: some View {
        VStack(spacing: 20) {
            // Encrypted text
            VStack(alignment: .leading) {
                if userSettings.showTextHelpers {
                    Text("Encrypted:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(game.encrypted)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .background(Color(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1)))
                    .cornerRadius(8)
            }
            
            // Solution with blocks
            VStack(alignment: .leading) {
                if userSettings.showTextHelpers {
                    Text("Your solution:")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                Text(game.currentDisplay)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .background(Color(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1)))
                    .cornerRadius(8)
            }
            
            // Game reset button - only show if game is completed
            if game.hasWon || game.hasLost {
                Button(action: resetGame) {
                    Label("New Game", systemImage: "arrow.clockwise")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.top, 8)
            }
        }
    }
    
    // Reset game function
    private func resetGame() {
        // If the game was won or lost, update statistics
        if (game.hasWon || game.hasLost) && game.gameId != nil {
            let score = game.hasWon ? game.calculateScore() : 0
            let timeTaken = Int(game.lastUpdateTime.timeIntervalSince(game.startTime))
            
            // Update stats in background
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try DatabaseManager.shared.updateStatistics(
                        userId: "local_user",
                        gameWon: game.hasWon,
                        mistakes: game.mistakes,
                        timeTaken: timeTaken,
                        score: score
                    )
                } catch {
                    print("Error updating statistics: \(error)")
                }
            }
        }
        
        // Create a new game
        game = Game()
        showWinMessage = false
        showLoseMessage = false
        showMatrixRain = false
    }
    
    // Win message overlay
    private var winMessageOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("You Win!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.green)
                
                Text(game.solution)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                
                // Score display
                VStack(spacing: 8) {
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text("\(game.calculateScore())")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)
                
                // Game stats
                HStack(spacing: 30) {
                    VStack {
                        Text("Mistakes")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(game.mistakes)/\(game.maxMistakes)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    VStack {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(formatTime(Int(game.lastUpdateTime.timeIntervalSince(game.startTime))))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical)
                
                Button(action: resetGame) {
                    Text("Play Again")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(32)
            .background(Color(colorScheme == .dark ? .black : .white).opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
            .onAppear {
                // Show matrix rain with a short delay for better visual effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.8)) {
                        showMatrixRain = true
                    }
                }
            }
        }
    }
    
    // Lose message overlay
    private var loseMessageOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.largeTitle.bold())
                    .foregroundColor(.red)
                
                Text("The solution was:")
                    .foregroundColor(.white)
                
                Text(game.solution)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                
                // Game stats
                HStack(spacing: 30) {
                    VStack {
                        Text("Mistakes")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("\(game.mistakes)/\(game.maxMistakes)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    VStack {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(formatTime(Int(game.lastUpdateTime.timeIntervalSince(game.startTime))))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical)
                
                Button(action: resetGame) {
                    Text("Try Again")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(32)
            .background(Color(colorScheme == .dark ? .black : .white).opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
