import SwiftUI

struct GameGridsView: View {
    @Binding var game: Game
    @Binding var isDarkMode: Bool
    let showTextHelpers: Bool
    let onWin: () -> Void
    let onLose: () -> Void
    
    // Theme colors
    var primaryColor: Color {
        isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255)
    }
    
    var secondaryColor: Color {
        isDarkMode ? Color(white: 0.15) : Color(white: 0.95)
    }
    
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
                VStack(spacing: 20) {
                    encryptedGrid
                    hintButton
                    guessGrid
                }
            }
        }
    }
    
    // Encrypted letters grid (left side)
    private var encryptedGrid: some View {
        VStack(alignment: .center, spacing: 8) {
            if showTextHelpers {
                Text("Select a letter to decode:")
                    .font(.system(size: 12))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
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
                        },
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                        darkText: primaryColor
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = game.uniqueEncryptedLetters().count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: 36, height: 36)
                }
            }
            .frame(maxWidth: 220) // Limit maximum width
        }
        .padding(.horizontal, 8)
    }
    
    // Guess letters grid (right side)
    private var guessGrid: some View {
        VStack(alignment: .center, spacing: 8) {
            if showTextHelpers {
                Text("Guess with:")
                    .font(.system(size: 12))
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            
            // Create a fixed 5-column grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 5)
            
            // Get alphabet letters
            let uniqueLetters = Array(Set(game.solution.filter { $0.isLetter })).sorted()
            
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
                                        onWin()
                                    } else if game.hasLost {
                                        onLose()
                                    }
                                }
                            }
                        },
                        isDarkMode: isDarkMode,
                        primaryColor: primaryColor,
                        darkText: primaryColor
                    )
                }
                
                // Add invisible placeholder cells to maintain grid layout
                let totalLetters = uniqueLetters.count
                let placeholdersNeeded = (5 - (totalLetters % 5)) % 5
                
                ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                    Color.clear
                        .frame(width: 36, height: 36)
                }
            }
            .frame(maxWidth: 220) // Limit maximum width
        }
        .padding(.horizontal, 8)
    }
    
    // Hint button
    private var hintButton: some View {
        HintButtonView(
            remainingHints: game.maxMistakes - game.mistakes,
            isLoading: isHintInProgress,
            isDarkMode: isDarkMode,
            onHintRequested: {
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
            }
        )
    }
}

// Modified letter cells to better match the web design


//
//  GameGrids.swift
//  Decodey
//
//  Created by Daniel Horsley on 06/05/2025.
//

