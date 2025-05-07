import SwiftUI

// Custom view components for win and lose overlays
struct WinOverlayView: View {
    let solution: String
    let mistakes: Int
    let maxMistakes: Int
    let timeTaken: Int
    let score: Int
    let isDarkMode: Bool
    let appStyle: AppStyle
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("You Win!")
                .font(.system(size: appStyle.titleFontSize,
                       design: appStyle.fontFamily == "System" ? .default : .monospaced))
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? appStyle.darkText : appStyle.primaryColor)
            
            Text(solution)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
            
            // Score display
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
                    
                    Text("\(mistakes)/\(maxMistakes)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                VStack {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(formatTime(timeTaken))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            
            Button(action: onPlayAgain) {
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
    }
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct LoseOverlayView: View {
    let solution: String
    let mistakes: Int
    let maxMistakes: Int
    let timeTaken: Int
    let isDarkMode: Bool
    let appStyle: AppStyle
    let onTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over")
                .font(.system(size: appStyle.titleFontSize,
                       design: appStyle.fontFamily == "System" ? .default : .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.red)
            
            Text("The solution was:")
                .foregroundColor(.white)
                .padding(.top)
            
            Text(solution)
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
                    
                    Text("\(mistakes)/\(maxMistakes)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                VStack {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(formatTime(timeTaken))
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding(.vertical)
            
            Button(action: onTryAgain) {
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
    
    // Format time in seconds to MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Preview providers
struct WinOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        WinOverlayView(
            solution: "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.",
            mistakes: 2,
            maxMistakes: 7,
            timeTaken: 125,
            score: 745,
            isDarkMode: true,
            appStyle: AppStyle(),
            onPlayAgain: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray)
    }
}

struct LoseOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        LoseOverlayView(
            solution: "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.",
            mistakes: 7,
            maxMistakes: 7,
            timeTaken: 95,
            isDarkMode: true,
            appStyle: AppStyle(),
            onTryAgain: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray)
    }
}//
//  GameOverlayViews.swift
//  Decodey
//
//  Created by Daniel Horsley on 07/05/2025.
//

