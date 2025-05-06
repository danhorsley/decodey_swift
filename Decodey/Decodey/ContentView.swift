import SwiftUI
import SpriteKit
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ContentView: View {
    @State private var game = Game()
    @State private var showWinMessage = false
    @State private var showLoseMessage = false
    @State private var showMatrixRain = false
    @State private var showAboutSheet = false
    @State private var showSettingsSheet = false
    @State private var isMenuOpen = false
    
    // User settings
    @StateObject private var userSettings = UserSettings()
    @State private var isDarkMode: Bool
    
    // Text helpers setting from userSettings
    private var showTextHelpers: Bool {
        userSettings.showTextHelpers
    }
    
    // Initialize with state from settings
    init() {
        let savedIsDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        _isDarkMode = State(initialValue: savedIsDarkMode)
    }
    
    var body: some View {
        ZStack {
            // Background
            (isDarkMode ? Color(red: 34/255, green: 34/255, blue: 34/255) : Color.white)
                .edgesIgnoringSafeArea(.all)
                
            // Matrix rain effect (only visible when game is won)
            if showMatrixRain {
                MatrixRainEffect(active: showMatrixRain, color: SKColor(red: 76/255, green: 201/255, blue: 240/255, alpha: 1.0))
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: 12) {
                // Header
                HStack {
                    // Menu button
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isMenuOpen = true
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                            .font(.title2)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("decodey")
                        .font(.custom("Courier", size: 28).bold())
                        .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                    
                    Spacer()
                    
                    // Dark mode toggle as an icon
                    Button(action: {
                        isDarkMode.toggle()
                        userSettings.isDarkMode = isDarkMode
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Display encrypted and current text - always stacked vertically
                VStack(spacing: 12) {
                    // First text area (encrypted)
                    ZStack(alignment: .topLeading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                            .frame(maxWidth: .infinity)
                            
                        // Text content
                        VStack(alignment: .leading) {
                            // Only show helper text if enabled
                            if showTextHelpers {
                                Text("Encrypted:")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                            }
                            
                            Text(game.encrypted)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(.gray)
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
                            // Only show helper text if enabled
                            if showTextHelpers {
                                Text("Your solution:")
                                    .font(.system(size: 12))
                                    .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                            }
                            
                            Text(game.currentDisplay)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                                .padding(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                
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
                                .background(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                // Game Dashboard
                GameDashboardView(
                    game: $game,
                    showWinMessage: $showWinMessage,
                    showLoseMessage: $showLoseMessage,
                    isDarkMode: $isDarkMode,
                    primaryColor: Color(red: 0/255, green: 66/255, blue: 170/255),
                    darkText: Color(red: 76/255, green: 201/255, blue: 240/255),
                    showTextHelpers: showTextHelpers
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
                        // Show matrix rain with a short delay for better visual effect
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeIn(duration: 0.8)) {
                                showMatrixRain = true
                            }
                        }
                    }
                    .onDisappear {
                        // Ensure matrix rain stops when overlay is dismissed
                        showMatrixRain = false
                    }
            }
            
            // Lose message overlay
            if showLoseMessage {
                loseOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: showLoseMessage)
            }
            
            // Slide menu
            if isMenuOpen {
                SlideMenuView(
                    isOpen: $isMenuOpen,
                    showAbout: $showAboutSheet,
                    showSettings: $showSettingsSheet
                )
            }
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SimpleSettingsView(settings: userSettings, isDarkMode: $isDarkMode)
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Win message overlay
    var winOverlay: some View {
        VStack(spacing: 12) {
            Text("You Win!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
            
            Text(game.solution)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
            
            // Score display
            let score = game.calculateScore()
            VStack(spacing: 8) {
                Text("SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding()
            .frame(width: 200)
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
            
            // Game stats
            HStack(spacing: 20) {
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
            
            Button(action: {
                // Reset the game and update statistics
                resetGame()
            }) {
                Text("Play Again")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .onAppear {
            // When win overlay appears, update statistics
            if game.gameId != nil {
                let score = game.calculateScore()
                let timeTaken = Int(game.lastUpdateTime.timeIntervalSince(game.startTime))
                
                // Update stats in background
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try DatabaseManager.shared.updateStatistics(
                            userId: "local_user",
                            gameWon: true,
                            mistakes: game.mistakes,
                            timeTaken: timeTaken,
                            score: score
                        )
                    } catch {
                        print("Error updating statistics: \(error)")
                    }
                }
            }
        }
    }
    
    // Lose message overlay
    var loseOverlay: some View {
        VStack(spacing: 12) {
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
                .padding(.horizontal)
            
            // Game stats
            HStack(spacing: 20) {
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
            
            Button(action: {
                // Reset the game and update statistics
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
        .onAppear {
            // When lose overlay appears, update statistics
            if game.gameId != nil {
                let timeTaken = Int(game.lastUpdateTime.timeIntervalSince(game.startTime))
                
                // Update stats in background
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try DatabaseManager.shared.updateStatistics(
                            userId: "local_user",
                            gameWon: false,
                            mistakes: game.mistakes,
                            timeTaken: timeTaken,
                            score: 0 // No score for losses
                        )
                    } catch {
                        print("Error updating statistics: \(error)")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
