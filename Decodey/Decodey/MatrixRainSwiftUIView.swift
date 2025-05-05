import SwiftUI
import SpriteKit

struct MatrixRainSwiftUIView: UIViewRepresentable {
    let active: Bool
    let color: SKColor
    
    class Coordinator {
        var scene: MatrixRainView?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        // Removed isOpaque = false, as it's read-only. Transparency is handled by the scene.
        let scene = MatrixRainView(size: skView.bounds.size)
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
