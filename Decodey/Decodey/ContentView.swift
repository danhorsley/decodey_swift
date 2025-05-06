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
    @State private var showStyleEditorSheet = false
    @State private var isMenuOpen = false
    
    // User settings
    @StateObject private var userSettings = UserSettings()
    // Style settings
    @StateObject private var appStyle = AppStyle()
    
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
            // Background - now using appStyle
            (isDarkMode ? appStyle.darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
                
            // Matrix rain effect (only visible when game is won)
            if showMatrixRain {
                MatrixRainEffect(active: showMatrixRain, color: isDarkMode ?
                    convertToSKColor(color: appStyle.darkText) :
                    convertToSKColor(color: appStyle.primaryColor))
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: appStyle.letterSpacing * 3) {
                // Header
                HStack {
                    // Menu button
                    Button(action: {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isMenuOpen = true
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                            .font(.title2)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text("decodey")
                        .font(.system(size: appStyle.titleFontSize,
                               design: appStyle.fontFamily == "Courier" || appStyle.fontFamily == "Menlo" ||
                                      appStyle.fontFamily == "SF Mono" ? .monospaced : .default))
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                    
                    Spacer()
                    
                    // Dark mode toggle as an icon
                    Button(action: {
                        isDarkMode.toggle()
                        userSettings.isDarkMode = isDarkMode
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                            .font(.title2)
                    }
                    .padding(.trailing)
                }
                .padding(.top)
                
                // Display encrypted and current text
                VStack(spacing: appStyle.letterSpacing * 2) {
                    // Encrypted text with monospaced font
                    VStack(alignment: .leading, spacing: appStyle.letterSpacing / 2) {
                        if showTextHelpers {
                            Text("Encrypted:")
                                .font(.system(size: appStyle.captionFontSize))
                                .foregroundColor(.gray)
                        }
                        
                        Text(game.encrypted)
                            .font(.system(size: appStyle.bodyFontSize,
                                  design: appStyle.fontFamily == "System" ? .default : .monospaced))
                            .tracking(appStyle.textLetterSpacing) // Use style for letter spacing
                            .lineSpacing(appStyle.textLineSpacing) // Use style for line spacing
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, appStyle.contentPadding)
                    
                    // Solution with blocks
                    VStack(alignment: .leading, spacing: appStyle.letterSpacing / 2) {
                        if showTextHelpers {
                            Text("Your solution:")
                                .font(.system(size: appStyle.captionFontSize))
                                .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                        }
                        
                        Text(game.currentDisplay)
                            .font(.system(size: appStyle.bodyFontSize,
                                  design: appStyle.fontFamily == "System" ? .default : .monospaced))
                            .tracking(appStyle.textLetterSpacing) // Use style for letter spacing
                            .lineSpacing(appStyle.textLineSpacing) // Use style for line spacing
                            .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, appStyle.contentPadding)
                }
                .padding(.vertical, appStyle.letterSpacing * 3)
                
                // Game reset button - only show if game is completed
                if game.hasWon || game.hasLost {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            resetGame()
                        }) {
                            Label("New Game", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, appStyle.contentPadding)
                }
                
                // Game grids with hint button - now using appStyle
                GameGridsView(
                    game: $game,
                    isDarkMode: $isDarkMode,
                    primaryColor: isDarkMode ? appStyle.darkText : appStyle.primaryColor,
                    darkText: appStyle.darkText,
                    letterCellSize: appStyle.letterCellSize,
                    guessLetterCellSize: appStyle.guessLetterCellSize,
                    letterSpacing: appStyle.letterSpacing,
                    fontFamily: appStyle.fontFamily,
                    fontSize: appStyle.bodyFontSize,
                    showTextHelpers: showTextHelpers,
                    onWin: {
                        showWinMessage = true
                    },
                    onLose: {
                        showLoseMessage = true
                    }
                )
                .padding(.top, appStyle.letterSpacing)
                
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
                    showSettings: $showSettingsSheet,
                    showStyleEditor: $showStyleEditorSheet
                )
                .environmentObject(appStyle)
            }
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SimpleSettingsView(settings: userSettings, isDarkMode: $isDarkMode)
        }
        .sheet(isPresented: $showStyleEditorSheet) {
            EnhancedStyleEditorView(appStyle: appStyle)
                .frame(minWidth: 600, idealWidth: 700, maxWidth: .infinity,
                       minHeight: 900, idealHeight: 1000, maxHeight: .infinity)
                #if os(iOS) || os(tvOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                #endif
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
                .font(.system(size: appStyle.titleFontSize,
                       design: appStyle.fontFamily == "System" ? .default : .monospaced))
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
            
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
                    .background(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
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
                .font(.system(size: appStyle.titleFontSize,
                       design: appStyle.fontFamily == "System" ? .default : .monospaced))
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
