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
    @State private var showStatsSheet = false
    @State private var showQuoteManagerSheet = false
    @State private var showStyleEditorSheet = false
    
    // Style management
    @StateObject private var appStyle = AppStyle.load() ?? AppStyle()
    @State private var isDarkMode = true
    
    // Layout settings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            // Background
            (isDarkMode ? appStyle.darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
                
            // Matrix rain effect (only visible when game is won)
            MatrixRainEffect(active: showMatrixRain, color: convertToSKColor(color: appStyle.darkText))
            
            VStack(spacing: appStyle.letterSpacing * 2) {
                // Header
                HStack {
                    Menu {
                        Button(action: {
                            showStatsSheet = true
                        }) {
                            Label("Statistics", systemImage: "chart.bar")
                        }
                        
                        Button(action: {
                            showQuoteManagerSheet = true
                        }) {
                            Label("Manage Quotes", systemImage: "quote.bubble")
                        }
                        
                        Button(action: {
                            showStyleEditorSheet = true
                        }) {
                            Label("Style Editor", systemImage: "paintbrush")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            resetGame()
                        }) {
                            Label("New Game", systemImage: "gamecontroller")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                            .font(.title2)
                    }
                    .padding(.leading, appStyle.contentPadding)
                    
                    Spacer()
                    
                    Text("decodey")
                        .font(.custom("Courier", size: appStyle.titleFontSize).bold())
                        .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                    
                    Spacer()
                    
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                            .font(.title2)
                    }
                    .padding(.trailing, appStyle.contentPadding)
                }
                .padding(.top)
                
                // Display encrypted and current text - always stacked vertically
                VStack(spacing: appStyle.letterSpacing) {
                    // First text area (encrypted)
                    ZStack(alignment: .topLeading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isDarkMode ? Color(white: 0.15) : Color(white: 0.95))
                            .frame(maxWidth: .infinity)
                            
                        // Text content
                        VStack(alignment: .leading) {
                            Text("Encrypted:")
                                .font(.system(size: appStyle.captionFontSize))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 8)
                            
                            Text(game.encrypted)
                                .font(.system(size: appStyle.bodyFontSize, design: .monospaced))
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
                            Text("Your solution:")
                                .font(.system(size: appStyle.captionFontSize))
                                .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                                .padding(.top, 8)
                                .padding(.leading, 8)
                            
                            Text(game.currentDisplay)
                                .font(.system(size: appStyle.bodyFontSize, design: .monospaced))
                                .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                                .padding(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, appStyle.contentPadding)
                
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
                                .background(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, appStyle.contentPadding)
                
                // Game Dashboard
                GameDashboardView(
                    game: $game,
                    showWinMessage: $showWinMessage,
                    showLoseMessage: $showLoseMessage,
                    isDarkMode: $isDarkMode,
                    primaryColor: appStyle.primaryColor,
                    darkText: appStyle.darkText
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
        }
        .sheet(isPresented: $showStatsSheet) {
            StatisticsView()
        }
        .sheet(isPresented: $showQuoteManagerSheet) {
            QuoteManagerView()
        }
        .sheet(isPresented: $showStyleEditorSheet) {
            StyleEditorView(appStyle: appStyle)
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
        VStack(spacing: appStyle.letterSpacing * 2) {
            Text("You Win!")
                .font(.title)
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
        VStack(spacing: appStyle.letterSpacing * 2) {
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

func convertToSKColor(color: Color) -> SKColor {
    #if os(iOS) || os(tvOS)
    let uiColor = UIColor(color)
    return SKColor(red: CGFloat(uiColor.cgColor.components?[0] ?? 0),
                  green: CGFloat(uiColor.cgColor.components?[1] ?? 0),
                   blue: CGFloat(uiColor.cgColor.components?[2] ?? 0),
                  alpha: CGFloat(uiColor.cgColor.components?[3] ?? 1))
    #elseif os(macOS)
    let nsColor = NSColor(color)
    return NSColor(red: CGFloat(nsColor.redComponent),
                 green: CGFloat(nsColor.greenComponent),
                  blue: CGFloat(nsColor.blueComponent),
                 alpha: CGFloat(nsColor.alphaComponent))
    #endif
}
