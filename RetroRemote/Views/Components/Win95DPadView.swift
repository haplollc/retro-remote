import SwiftUI

/// A Windows 95-style D-pad - simplified single border, properly centered
struct Win95DPadView: View {
    let onButtonPress: (RemoteButton) -> Void
    
    private let buttonSize: CGFloat = Win95ButtonSizes.dpadArrowSize
    private let okSize: CGFloat = Win95ButtonSizes.okButtonSize
    private let spacing: CGFloat = 4
    
    var body: some View {
        // Simple sunken panel for the D-pad
        VStack(spacing: spacing) {
            // Up arrow
            Win95Button(button: .up) {
                onButtonPress(.up)
            }
            
            // Left - OK - Right row
            HStack(spacing: spacing) {
                Win95Button(button: .left) {
                    onButtonPress(.left)
                }
                
                Win95Button(button: .select) {
                    onButtonPress(.select)
                }
                
                Win95Button(button: .right) {
                    onButtonPress(.right)
                }
            }
            
            // Down arrow
            Win95Button(button: .down) {
                onButtonPress(.down)
            }
        }
        .padding(12)
        .background(Win95Theme.silver)
        .overlay(
            SunkenBorderView()
        )
    }
}

#Preview {
    Win95DPadView { button in
        print("Pressed: \(button)")
    }
    .padding()
    .background(Win95Theme.silver)
}
