import SwiftUI

/// A Windows 95 Minesweeper-style button with beveled 3D edges
struct Win95Button: View {
    let button: RemoteButton
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.none) {
                isPressed = true
            }
            
            HapticManager.shared.hapticForButton(button)
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.none) {
                    isPressed = false
                }
            }
        }) {
            buttonContent
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        switch button {
        case .power:
            Win95PowerButton(isPressed: isPressed)
        case .up, .down, .left, .right:
            Win95DirectionalButton(button: button, isPressed: isPressed)
        case .select:
            Win95SelectButton(isPressed: isPressed)
        case .volumeUp, .volumeDown:
            Win95VolumeButton(button: button, isPressed: isPressed)
        case .channelUp, .channelDown:
            Win95ChannelButton(button: button, isPressed: isPressed)
        case .num0, .num1, .num2, .num3, .num4, .num5, .num6, .num7, .num8, .num9:
            Win95NumberButton(button: button, isPressed: isPressed)
        case .play, .pause, .stop, .rewind, .fastForward:
            Win95PlaybackButton(button: button, isPressed: isPressed)
        case .mute:
            Win95MuteButton(isPressed: isPressed)
        default:
            Win95GenericButton(button: button, isPressed: isPressed)
        }
    }
}

// MARK: - Power Button

struct Win95PowerButton: View {
    let isPressed: Bool
    
    var body: some View {
        ZStack {
            // Classic red button with win95 bevel
            Text("⏻")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Rectangle()
                        .fill(Color(red: 0.7, green: 0.1, blue: 0.1))
                )
                .overlay(
                    Win95ButtonBevel(isPressed: isPressed, baseColor: Color(red: 0.7, green: 0.1, blue: 0.1))
                )
                .offset(y: isPressed ? 1 : 0)
        }
    }
}

// MARK: - Select/OK Button

struct Win95SelectButton: View {
    let isPressed: Bool
    
    var body: some View {
        ZStack {
            Text("OK")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Rectangle()
                        .fill(Color(red: 0.0, green: 0.0, blue: 0.6))
                )
                .overlay(
                    Win95ButtonBevel(isPressed: isPressed, baseColor: Color(red: 0.0, green: 0.0, blue: 0.6))
                )
                .offset(y: isPressed ? 1 : 0)
        }
    }
}

// MARK: - Directional Button

struct Win95DirectionalButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    private var arrowText: String {
        switch button {
        case .up: return "▲"
        case .down: return "▼"
        case .left: return "◀"
        case .right: return "▶"
        default: return ""
        }
    }
    
    var body: some View {
        Text(arrowText)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 44, height: 36)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Volume Button

struct Win95VolumeButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    var body: some View {
        HStack(spacing: 2) {
            Text("🔊")
                .font(.system(size: 12))
            Text(button == .volumeUp ? "+" : "−")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
        }
        .frame(width: 54, height: 36)
        .background(Win95Theme.silver)
        .overlay(
            Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
        )
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Channel Button

struct Win95ChannelButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    var body: some View {
        Text(button == .channelUp ? "CH+" : "CH−")
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: 54, height: 36)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Number Button

struct Win95NumberButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    var body: some View {
        Text(button.displayName)
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: 46, height: 46)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Playback Button

struct Win95PlaybackButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    private var iconText: String {
        switch button {
        case .play: return "▶"
        case .pause: return "⏸"
        case .stop: return "■"
        case .rewind: return "◀◀"
        case .fastForward: return "▶▶"
        default: return "?"
        }
    }
    
    var body: some View {
        Text(iconText)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 40, height: 36)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Mute Button

struct Win95MuteButton: View {
    let isPressed: Bool
    
    var body: some View {
        Text("🔇")
            .font(.system(size: 16))
            .frame(width: 46, height: 46)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Generic Button

struct Win95GenericButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    private var iconText: String {
        switch button {
        case .home: return "🏠"
        case .menu: return "☰"
        case .back: return "←"
        default: return "●"
        }
    }
    
    var body: some View {
        Text(iconText)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.black)
            .frame(width: 46, height: 38)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Win95 Button Bevel Helper

struct Win95ButtonBevel: View {
    let isPressed: Bool
    let baseColor: Color
    
    var topLeftColor: Color {
        isPressed ? Win95Theme.black : Win95Theme.white
    }
    
    var bottomRightColor: Color {
        isPressed ? Win95Theme.white : Win95Theme.black
    }
    
    var innerTopLeftColor: Color {
        isPressed ? Win95Theme.darkGray : Win95Theme.lightGray
    }
    
    var innerBottomRightColor: Color {
        isPressed ? Win95Theme.lightGray : Win95Theme.darkGray
    }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            // Outer top-left highlight
            Path { path in
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w - 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: 2))
                path.addLine(to: CGPoint(x: 2, y: h - 2))
                path.closeSubpath()
            }
            .fill(topLeftColor)
            
            // Inner top-left
            Path { path in
                path.move(to: CGPoint(x: 2, y: h - 2))
                path.addLine(to: CGPoint(x: 2, y: 2))
                path.addLine(to: CGPoint(x: w - 2, y: 2))
            }
            .stroke(innerTopLeftColor, lineWidth: 1)
            
            // Outer bottom-right shadow
            Path { path in
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 2, y: h - 2))
                path.addLine(to: CGPoint(x: w - 2, y: h - 2))
                path.addLine(to: CGPoint(x: w - 2, y: 2))
                path.closeSubpath()
            }
            .fill(bottomRightColor)
            
            // Inner bottom-right
            Path { path in
                path.move(to: CGPoint(x: w - 3, y: 3))
                path.addLine(to: CGPoint(x: w - 3, y: h - 3))
                path.addLine(to: CGPoint(x: 3, y: h - 3))
            }
            .stroke(innerBottomRightColor, lineWidth: 1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Win95Button(button: .power) {}
        HStack(spacing: 15) {
            Win95Button(button: .volumeUp) {}
            Win95Button(button: .volumeDown) {}
        }
        Win95Button(button: .select) {}
        HStack(spacing: 10) {
            Win95Button(button: .num1) {}
            Win95Button(button: .num2) {}
            Win95Button(button: .num3) {}
        }
        HStack(spacing: 10) {
            Win95Button(button: .play) {}
            Win95Button(button: .pause) {}
            Win95Button(button: .stop) {}
        }
    }
    .padding(30)
    .background(Win95Theme.silver)
}
