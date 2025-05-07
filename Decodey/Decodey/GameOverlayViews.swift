import SwiftUI

// Custom view components for win and lose overlays
struct WinOverlayView: View {
    let solution: String
    let mistakes: Int
    let maxMistakes: Int
    let timeTaken: Int
    let score: Int
    let isDarkMode: Bool
    let onPlayAgain: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text("You Win!")
                .font(.largeTitle.bold())
                .foregroundColor(.green)
            
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
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(BorderlessButtonStyle())
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
    let onTryAgain: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over")
                .font(.largeTitle.bold())
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
            .buttonStyle(BorderlessButtonStyle())
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
            onPlayAgain: {}
        )
        .previewLayout(.fixed(width: 350, height: 500))
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
            onTryAgain: {}
        )
        .previewLayout(.fixed(width: 350, height: 500))
        .padding()
        .background(Color.gray)
    }
}
