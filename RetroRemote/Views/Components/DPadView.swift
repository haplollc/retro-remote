import SwiftUI

/// A directional pad (D-pad) that looks like a real physical controller
struct DPadView: View {
    let onButtonPress: (RemoteButton) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    private var baseColor: Color {
        colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.75)
    }
    
    private var highlightColor: Color {
        colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.9)
    }
    
    var body: some View {
        ZStack {
            // Base plate (metallic look)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [baseColor, baseColor.opacity(0.8)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // Brushed metal texture overlay
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.white.opacity(0.05),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ],
                        center: .center
                    )
                )
                .frame(width: 198, height: 198)
            
            // Inner ring shadow
            Circle()
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                .frame(width: 180, height: 180)
            
            // Direction buttons
            VStack(spacing: 0) {
                // Up
                SkeuomorphicButton(button: .up) {
                    onButtonPress(.up)
                }
                
                HStack(spacing: 20) {
                    // Left
                    SkeuomorphicButton(button: .left) {
                        onButtonPress(.left)
                    }
                    
                    // Center OK button
                    SkeuomorphicButton(button: .select) {
                        onButtonPress(.select)
                    }
                    
                    // Right
                    SkeuomorphicButton(button: .right) {
                        onButtonPress(.right)
                    }
                }
                
                // Down
                SkeuomorphicButton(button: .down) {
                    onButtonPress(.down)
                }
            }
        }
    }
}

#Preview {
    DPadView { button in
        print("Pressed: \(button)")
    }
    .padding()
    .background(Color(white: 0.1))
}
