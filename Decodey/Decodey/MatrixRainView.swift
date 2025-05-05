import SwiftUI

struct MatrixRainView: View {
    let darkText = Color(red: 76/255, green: 201/255, blue: 240/255) // #4cc9f0
    let matrixGreen = Color(red: 0/255, green: 255/255, blue: 65/255) // #00ff41
    
    let active: Bool
    let color: Color
    
    @State private var raindrops: [Raindrop] = []
    @State private var size: CGSize = .zero
    
    // Configuration
    let density: Int = 15
    let speedFactor: Double = 1.0
    
    // Characters to use
    let chars = "01♠♥♦♣※⧠⧫⁂☤⚕☢⚛☯☸⟁⟒ΘΔΦΨΩ"
    
    // Timer for animation
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ForEach(raindrops.indices, id: \.self) { index in
                    if index < raindrops.count {
                        Text(String(raindrops[index].char))
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(color.opacity(raindrops[index].opacity))
                            .position(x: raindrops[index].x,
                                      y: raindrops[index].y)
                    }
                }
                .onAppear {
                    size = geometry.size
                    initializeRaindrops()
                }
                // Modern onChange syntax with no parameters
                .onChange(of: geometry.size) {
                    // Access the new value using geometry.size, which is already updated
                    size = geometry.size
                    initializeRaindrops()
                }
            }
        }
        .opacity(active ? 1 : 0)
        .animation(.easeInOut, value: active)
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
        let columnWidth: CGFloat = fontSize * 1.2
        let columns = Int(size.width / columnWidth)
        
        // Create raindrops
        for i in 0..<min(columns, density) {
            let x = CGFloat(i) * (size.width / CGFloat(min(columns, density)))
            let y = CGFloat.random(in: -size.height..<0)
            let speed = Double.random(in: 1...3) * speedFactor
            let char = chars.randomElement() ?? "0"
            let opacity = Double.random(in: 0.5...1.0)
            
            raindrops.append(Raindrop(x: x, y: y, speed: speed, char: char, opacity: opacity))
        }
    }
    
    private func updateRaindrops() {
        for i in 0..<raindrops.count {
            // Move the raindrop down
            raindrops[i].y += CGFloat(raindrops[i].speed)
            
            // Occasionally change the character
            if Int.random(in: 0...10) == 0 {
                raindrops[i].char = chars.randomElement() ?? "0"
            }
            
            // Reset if it's gone off screen
            if raindrops[i].y > size.height {
                raindrops[i].y = CGFloat.random(in: -50..<0)
                raindrops[i].speed = Double.random(in: 1...3) * speedFactor
                raindrops[i].opacity = Double.random(in: 0.5...1.0)
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
//  MatrixRainView.swift
//  Decodey
//
//  Created by Daniel Horsley on 05/05/2025.
//

