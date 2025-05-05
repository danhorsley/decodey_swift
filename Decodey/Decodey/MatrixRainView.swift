import SpriteKit

class MatrixRainView: SKScene {
    private var drops: [CGFloat] = []
    private var speeds: [CGFloat] = []
    private var characters: [Character] = []
    private var nodes: [[SKLabelNode]] = [] // Array of nodes for head and trail
    private let fontSize: CGFloat = 14
    private let color = SKColor(red: 0, green: 1, blue: 0.255, alpha: 1) // #00ff41
    private let fadeSpeed: CGFloat = 0.05
    private let speedFactor: CGFloat = 1.0
    private let chars = "01ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ♠♥♦♣★☆⋆§¶†‡※⁂⁑⁎⁕≡≈≠≤≥÷«»"
    private var isActive: Bool = true
    
    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = .clear
        scaleMode = .resizeFill
        initializeDrops()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        scaleMode = .resizeFill
        initializeDrops()
    }
    
    private func initializeDrops() {
        removeAllChildren()
        drops.removeAll()
        speeds.removeAll()
        characters.removeAll()
        nodes.removeAll()
        
        let columns = Int(size.width / fontSize)
        drops = Array(repeating: 0, count: columns)
        speeds = Array(repeating: 0, count: columns)
        characters = Array(repeating: "0", count: columns)
        nodes = Array(repeating: [], count: columns)
        
        for i in 0..<columns {
            drops[i] = CGFloat.random(in: -size.height / fontSize...0)
            speeds[i] = (CGFloat.random(in: 0.5...1) * speedFactor)
            characters[i] = chars.randomElement() ?? "0"
            
            // Create head and trail nodes
            for j in 0..<20 { // Up to 20 trail characters
                let node = SKLabelNode(fontNamed: "Menlo")
                node.fontSize = fontSize
                node.fontColor = color
                node.text = String(characters[i])
                node.position = CGPoint(x: CGFloat(i) * fontSize + fontSize / 2, y: (drops[i] - CGFloat(j)) * fontSize)
                node.alpha = j == 0 ? 1 : pow(0.8, CGFloat(j)) // Head at full opacity, trail decays
                node.zPosition = CGFloat(-j) // Ensure head is on top
                nodes[i].append(node)
                addChild(node)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval TRUE) {
        guard isActive else { return }
        
        // Apply fade effect to background
        let fadeNode = SKShapeNode(rect: frame)
        fadeNode.fillColor = .black.withAlphaComponent(fadeSpeed * 1.5)
        fadeNode.zPosition = -100
        addChild(fadeNode)
        fadeNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.removeFromParent()
        ]))
        
        // Update drops
        for i in 0..<drops.count {
            drops[i] += speeds[i]
            
            // Occasionally change character
            if Int.random(in: 0...8) == 0 {
                characters[i] = chars.randomElement() ?? "0"
            }
            
            // Update node positions and text
            for j in 0..<nodes[i].count {
                let y = (drops[i] - CGFloat(j)) * fontSize
                nodes[i][j].position.y = y
                nodes[i][j].text = String(characters[i])
                nodes[i][j].alpha = j == 0 ? 1 : pow(0.8, CGFloat(j)) // Update trail opacity
            }
            
            // Reset drop when it goes off screen
            if drops[i] * fontSize > size.height && Bool.random(probability: 0.025) {
                drops[i] = CGFloat.random(in: -20...0)
                speeds[i] = (CGFloat.random(in: 0.5...1) * speedFactor)
                characters[i] = chars.randomElement() ?? "0"
                for j in 0..<nodes[i].count {
                    nodes[i][j].position.y = (drops[i] - CGFloat(j)) * fontSize
                    nodes[i][j].text = String(characters[i])
                }
            }
        }
    }
    
    func setActive(_ active: Bool) {
        isActive = active
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        initializeDrops()
    }
}

// Extension for random probability
extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) > (1 - probability)
    }
}
