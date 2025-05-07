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
    @EnvironmentObject var appStyle: AppStyle
    
    @State private var isDarkMode: Bool
    
    // Text helpers setting from userSettings
    private var showTextHelpers: Bool {
        userSettings.showTextHelpers
    }
    
    // Status color for hint button
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
    
    // Initialize with state from settings
    init() {
        let savedIsDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        _isDarkMode = State(initialValue: savedIsDarkMode)
    }
    
    var body: some View {
        ZStack {
            // Background - using appStyle
            (isDarkMode ? appStyle.darkBackground : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            // Matrix rain effect (only visible when game is won)
            if showMatrixRain {
                MatrixRainEffect(active: showMatrixRain, color: isDarkMode ?
                                 convertToSKColor(color: appStyle.darkText) :
                                    convertToSKColor(color: appStyle.primaryColor))
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack(spacing: appStyle.letterSpacing * 2) {
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
                                      design: appStyle.fontFamily == "Courier" || appStyle.fontFamily == "Menlo" ? .monospaced : .default))
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
                VStack(spacing: appStyle.textDisplaySpacing) { // Using new textDisplaySpacing property
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
                            .frame(maxWidth: .infinity, alignment: .center) // Always center text
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
                            .frame(maxWidth: .infinity, alignment: .center) // Always center text
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, appStyle.contentPadding)
                }
                .padding(.top, appStyle.letterSpacing * 2)
                .padding(.bottom, appStyle.textToGridSpacing) // Using new textToGridSpacing property
                
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
                
                // Game dashboard with grids and hint button
                GeometryReader { geometry in
                    let isLandscape = geometry.size.width > geometry.size.height
                    
                    if isLandscape {
                        // Landscape layout
                        HStack(alignment: .top, spacing: 0) {
                            // Encrypted grid on left with margin
                            encryptedGrid
                                .padding(.leading, appStyle.gridMargin)
                                .frame(maxWidth: .infinity)
                            
                            // Hint button in the center with vertical padding
                            VStack {
                                Spacer()
                                    .frame(height: appStyle.hintButtonTopPadding)
                                
                                hintButton
                                
                                Spacer()
                                    .frame(height: appStyle.hintButtonBottomPadding)
                            }
                            .frame(width: 130)
                            
                            // Guess grid on right with margin
                            guessGrid
                                .padding(.trailing, appStyle.gridMargin)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        // Portrait layout
                        VStack(spacing: appStyle.letterSpacing * 3) {
                            // Center the grids in portrait mode
                            encryptedGrid
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // Add vertical padding around hint button
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
                
                Spacer()
            }
            
            // Win message overlay
            if showWinMessage {
                WinOverlayView(
                    solution: game.solution,
                    mistakes: game.mistakes,
                    maxMistakes: game.maxMistakes,
                    timeTaken: Int(game.lastUpdateTime.timeIntervalSince(game.startTime)),
                    score: game.calculateScore(),
                    isDarkMode: isDarkMode,
                    appStyle: appStyle,
                    onPlayAgain: resetGame
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: showWinMessage)
                .onAppear {
                    // Show matrix rain with a short delay for better visual effect
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeIn(duration: 0.8)) {
                            showMatrixRain = true
                        }
                    }
                    
                    // Update statistics
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
                .onDisappear {
                    // Ensure matrix rain stops when overlay is dismissed
                    showMatrixRain = false
                }
            }
            
            // Lose message overlay
            if showLoseMessage {
                LoseOverlayView(
                    solution: game.solution,
                    mistakes: game.mistakes,
                    maxMistakes: game.maxMistakes,
                    timeTaken: Int(game.lastUpdateTime.timeIntervalSince(game.startTime)),
                    isDarkMode: isDarkMode,
                    appStyle: appStyle,
                    onTryAgain: resetGame
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: showLoseMessage)
                .onAppear {
                    // Update statistics
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
                                        showWinMessage = true
                                    } else if game.hasLost {
                                        showLoseMessage = true
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
        @State var isHintInProgress = false
        
        return Button(action: {
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
                    showWinMessage = true
                } else if game.hasLost {
                    showLoseMessage = true
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
}
