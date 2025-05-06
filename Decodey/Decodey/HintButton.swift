import SwiftUI

struct HintButtonView: View {
    let remainingHints: Int
    let isLoading: Bool
    let isDarkMode: Bool
    let onHintRequested: () -> Void
    
    // Colors based on theme
    var primaryColor: Color {
        isDarkMode ? Color(red: 76/255, green: 201/255, blue: 240/255) : Color(red: 0/255, green: 66/255, blue: 170/255)
    }
    
    var backgroundColor: Color {
        isDarkMode ? Color(white: 0.15) : Color(white: 0.95)
    }
    
    // Convert remaining hint count to text representation
    private var hintText: String {
        switch remainingHints {
        case 7:
            return "█SIX█"
        case 6:
            return "█FIVE"
        case 5:
            return "FOUR█"
        case 4:
            return "THREE"
        case 3:
            return "█TWO█"
        case 2:
            return "█ONE█"
        case 1:
            return "ZERO█"
        case 0:
            return "█NIL█"
        default:
            if remainingHints > 7 {
                return "MANY█"
            } else {
                return "█NIL█"
            }
        }
    }
    
    // Determine the status color based on remaining hints
    private var statusColor: Color {
        if remainingHints <= 1 {
            return .red
        } else if remainingHints <= 3 {
            return .orange
        } else {
            return primaryColor
        }
    }
    
    var body: some View {
        Button(action: onHintRequested) {
            VStack(spacing: 4) {
                // Show spinner when hint is loading
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: isDarkMode ? primaryColor : primaryColor))
                        .frame(height: 30)
                        .padding(.vertical, 4)
                } else {
                    // Hint text with monospaced font
                    Text(hintText)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                        .frame(height: 30)
                }
                
                // Label underneath
                Text("HINT TOKENS")
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(width: 110, height: 70)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(statusColor, lineWidth: 2)
            )
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || remainingHints <= 0)
    }
}

struct HintButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ForEach([7, 6, 5, 4, 3, 2, 1, 0], id: \.self) { count in
                HintButtonView(
                    remainingHints: count,
                    isLoading: false,
                    isDarkMode: true,
                    onHintRequested: {}
                )
            }
            
            HintButtonView(
                remainingHints: 5,
                isLoading: true,
                isDarkMode: true,
                onHintRequested: {}
            )
        }
        .padding()
        .background(Color(white: 0.1))
        .previewLayout(.sizeThatFits)
    }
}//
//  HintButton.swift
//  Decodey
//
//  Created by Daniel Horsley on 06/05/2025.
//

