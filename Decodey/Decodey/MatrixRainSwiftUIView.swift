import SwiftUI
import SpriteKit

#if os(iOS) || os(tvOS)
struct MatrixRainSwiftUIView: UIViewRepresentable {
    let active: Bool
    let color: SKColor
    
    class Coordinator {
        var scene: MatrixRainScene?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        let scene = MatrixRainScene(size: skView.bounds.size)
        scene.setActive(active)
        skView.presentScene(scene)
        context.coordinator.scene = scene
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        context.coordinator.scene?.setActive(active)
        context.coordinator.scene?.size = uiView.bounds.size
    }
}
#elseif os(macOS)
struct MatrixRainSwiftUIView: NSViewRepresentable {
    let active: Bool
    let color: SKColor
    
    class Coordinator {
        var scene: MatrixRainScene?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        let scene = MatrixRainScene(size: skView.bounds.size)
        scene.setActive(active)
        skView.presentScene(scene)
        context.coordinator.scene = scene
        return skView
    }
    
    func updateNSView(_ nsView: SKView, context: Context) {
        context.coordinator.scene?.setActive(active)
        context.coordinator.scene?.size = nsView.bounds.size
    }
}
#endif

// Renamed the SpriteKit scene class to avoid naming conflicts
class MatrixRainScene: SKScene {
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
    
    // Rest of your implementation...
    
    override func update(_ currentTime: TimeInterval) {
        // Fixed the parameter type
        // Rest of your update method...
    }
    
    func setActive(_ active: Bool) {
        isActive = active
    }
}

// Now create a platform-agnostic SwiftUI wrapper
struct MatrixRainEffect: View {
    let active: Bool
    let color: SKColor
    
    var body: some View {
        MatrixRainSwiftUIView(active: active, color: color)
            .edgesIgnoringSafeArea(.all)
    }
}
