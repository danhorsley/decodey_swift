import SwiftUI

struct MatrixRainView: View {
    let active: Bool
    let color: Color
    
    @State private var raindrops: [Raindrop] = []
    @State private var size: CGSize = .zero
    
    // Configuration
    let density: Int = 20  // Increased density for better visual effect
    let speedFactor: Double = 1.2  // Slightly faster for more dynamic effect
    
    // Characters to use - include more cryptographic symbols for variety
    let chars = "01♠♥♦♣※⧠⧫⁂☤⚕☢⚛☯☸⟁⟒ΘΔΦΨΩ αβγδεζηθικλμνξπρστυφχψωАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
    
    // Timer for animation
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Semi-transparent black background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ForEach(raindrops.indices, id: \.self) { index in
                    if index < raindrops.count {
                        Text(String(raindrops[index].char))
                            .font(.system(size: 14, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(color.opacity(raindrops[index].opacity))
                            .position(x: raindrops[index].x,
                                      y: raindrops[index].y)
                            .shadow(color: color.opacity(0.8), radius: 1, x: 0, y: 0)
                    }
                }
                .onAppear {
                    size = geometry.size
                    initializeRaindrops()
                }
                // onChange handler for size changes
                .onChange(of: geometry.size) {
                    size = geometry.size
                    initializeRaindrops()
                }
            }
        }
        .opacity(active ? 1 : 0)
        .animation(.easeIn(duration: 0.6), value: active)
        .onReceive(timer) { _ in
            if active {
                updateRaindrops()
            }
        }
    }
    
    private func initializeRaindrops() {
        guard size.width > 0, size.height > 0 else { return }
        
        raindrops = []
        
        // Calculate number of columns based on width
        let fontSize: CGFloat = 14
        let columnWidth: CGFloat = fontSize * 1.0  // Slightly tighter spacing
        let columns = Int(size.width / columnWidth)
        
        // Create raindrops with more variety
        for i in 0..<min(columns, density) {
            let x = CGFloat(i) * (size.width / CGFloat(min(columns, density)))
            let y = CGFloat.random(in: -size.height..<0)
            let speed = Double.random(in: 1...4) * speedFactor
            let char = chars.randomElement() ?? "0"
            let opacity = Double.random(in: 0.5...1.0)
            
            raindrops.append(Raindrop(x: x, y: y, speed: speed, char: char, opacity: opacity))
        }
        
        // Add some extra raindrops for a more dense effect
        for _ in 0..<density/2 {
            let x = CGFloat.random(in: 0..<size.width)
            let y = CGFloat.random(in: -size.height..<0)
            let speed = Double.random(in: 1...4) * speedFactor
            let char = chars.randomElement() ?? "0"
            let opacity = Double.random(in: 0.5...1.0)
            
            raindrops.append(Raindrop(x: x, y: y, speed: speed, char: char, opacity: opacity))
        }
    }
    
    private func updateRaindrops() {
        for i in 0..<raindrops.count {
            // Move the raindrop down
            raindrops[i].y += CGFloat(raindrops[i].speed)
            
            // Occasionally change the character (more frequently for a dynamic effect)
            if Int.random(in: 0...5) == 0 {
                raindrops[i].char = chars.randomElement() ?? "0"
            }
            
            // Occasionally change the opacity for a "shimmer" effect
            if Int.random(in: 0...10) == 0 {
                raindrops[i].opacity = Double.random(in: 0.5...1.0)
            }
            
            // Reset if it's gone off screen
            if raindrops[i].y > size.height {
                raindrops[i].y = CGFloat.random(in: -50..<0)
                raindrops[i].speed = Double.random(in: 1...4) * speedFactor
                raindrops[i].opacity = Double.random(in: 0.5...1.0)
                raindrops[i].char = chars.randomElement() ?? "0"
            }
        }
    }
}

// Raindrop model
struct Raindrop {
    var x: CGFloat
    var y: CGFloat
    var speed: Double
    var char: Character
    var opacity: Double
}

struct MatrixRainView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MatrixRainView(
                active: true,
                color: Color(red: 76/255, green: 201/255, blue: 240/255)
            )
        }
    }
}
