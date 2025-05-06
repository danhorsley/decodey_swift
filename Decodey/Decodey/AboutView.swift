import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("Decodey: Crack the Code!")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    
                    // Game description
                    Text("A cryptography-based word puzzle game where you break the code to reveal famous quotes.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    // How to play section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How to Play")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text("1. Select a letter from the encrypted grid (left side)")
                        Text("2. Guess which original letter it represents from the alphabet grid (right side)")
                        Text("3. The number on each encrypted letter shows how many times it appears")
                        Text("4. Use pattern recognition to crack the code before running out of mistakes")
                        Text("5. Need help? Use a hint, but it will cost you one mistake")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
                    )
                    
                    // Strategy tips
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Strategy Tips")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text("• Start with high-frequency letters (E, T, A, O, I, N)")
                        Text("• Look for patterns like THE, AND, or ING")
                        Text("• Single-letter words are usually A or I")
                        Text("• Apostrophes are often followed by S, T, D, LL, or RE")
                        Text("• Use frequency analysis to identify common letters")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
                    )
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Credits")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Text("Original Flask/React app by Original Developer")
                        Text("Swift version by Swift Developer Team")
                        Text("All quotes are properly attributed to their authors")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
                    )
                    
                    // Version info
                    HStack {
                        Spacer()
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("About")
            // Platform specific modifiers
            #if os(iOS) || os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.dark)
    }
}
