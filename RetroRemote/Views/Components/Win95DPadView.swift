import SwiftUI

/// A Windows 95-style D-pad that looks like chunky plastic buttons
struct Win95DPadView: View {
    let onButtonPress: (RemoteButton) -> Void
    
    var body: some View {
        ZStack {
            // Sunken base plate
            RoundedRectangle(cornerRadius: 4)
                .fill(Win95Theme.silver)
                .frame(width: 190, height: 190)
                .overlay(
                    SunkenBorderView()
                        .padding(2)
                )
            
            // Inner raised platform
            RoundedRectangle(cornerRadius: 2)
                .fill(Win95Theme.silver)
                .frame(width: 170, height: 170)
                .overlay(
                    BeveledBorderView(isPressed: false, cornerRadius: 0)
                )
            
            // D-pad buttons arranged in cross pattern
            VStack(spacing: 0) {
                // Up
                Win95Button(button: .up) {
                    onButtonPress(.up)
                }
                
                HStack(spacing: 16) {
                    // Left
                    Win95Button(button: .left) {
                        onButtonPress(.left)
                    }
                    
                    // Center OK button
                    Win95Button(button: .select) {
                        onButtonPress(.select)
                    }
                    
                    // Right
                    Win95Button(button: .right) {
                        onButtonPress(.right)
                    }
                }
                
                // Down
                Win95Button(button: .down) {
                    onButtonPress(.down)
                }
            }
        }
    }
}

#Preview {
    Win95DPadView { button in
        print("Pressed: \(button)")
    }
    .padding()
    .background(Win95Theme.silver)
}
