import SwiftUI

/// A button that looks like a real physical button with 3D effects
struct SkeuomorphicButton: View {
    let button: RemoteButton
    let action: () -> Void
    
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.05)) {
                isPressed = true
            }
            
            HapticManager.shared.hapticForButton(button)
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.1)) {
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
            PowerButtonView(isPressed: isPressed, colorScheme: colorScheme)
        case .up, .down, .left, .right:
            DirectionalButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        case .select:
            SelectButtonView(isPressed: isPressed, colorScheme: colorScheme)
        case .volumeUp, .volumeDown:
            VolumeButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        case .channelUp, .channelDown:
            ChannelButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        case .num0, .num1, .num2, .num3, .num4, .num5, .num6, .num7, .num8, .num9:
            NumberButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        case .play, .pause, .stop, .rewind, .fastForward:
            PlaybackButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        case .mute:
            MuteButtonView(isPressed: isPressed, colorScheme: colorScheme)
        default:
            GenericButtonView(button: button, isPressed: isPressed, colorScheme: colorScheme)
        }
    }
}

// MARK: - Power Button

struct PowerButtonView: View {
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            // Button base with metallic effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.red.opacity(0.9),
                            Color.red.opacity(0.7),
                            Color(red: 0.6, green: 0.1, blue: 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: .black.opacity(0.5), radius: isPressed ? 2 : 5, x: 0, y: isPressed ? 1 : 3)
            
            // Inner highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 55, height: 55)
            
            // Power symbol
            Image(systemName: "power")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 2 : 0)
    }
}

// MARK: - Select Button (Center of D-pad)

struct SelectButtonView: View {
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color(white: 0.85)
    }
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .fill(
                    LinearGradient(
                        colors: [buttonColor.opacity(0.9), buttonColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 2 : 4, x: 0, y: isPressed ? 1 : 2)
            
            // Inner button
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.8),
                            Color.blue.opacity(0.6),
                            Color(red: 0.1, green: 0.2, blue: 0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
            
            // Highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.4), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 25
                    )
                )
                .frame(width: 55, height: 55)
            
            Text("OK")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 2 : 0)
    }
}

// MARK: - Directional Buttons

struct DirectionalButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.8)
    }
    
    private var rotation: Angle {
        switch button {
        case .up: return .degrees(0)
        case .right: return .degrees(90)
        case .down: return .degrees(180)
        case .left: return .degrees(270)
        default: return .degrees(0)
        }
    }
    
    var body: some View {
        ZStack {
            // Button shape (rounded trapezoid-like)
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 40)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            // Highlight
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 48, height: 38)
            
            // Arrow
            Image(systemName: "chevron.up")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
                .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.8), radius: 0.5, x: 0, y: colorScheme == .dark ? 1 : -1)
        }
        .rotationEffect(rotation)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Volume Buttons

struct VolumeButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color(white: 0.85)
    }
    
    var body: some View {
        ZStack {
            // Pill shape
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 55, height: 40)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            // Highlight
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 53, height: 38)
            
            // Symbol
            Image(systemName: button == .volumeUp ? "speaker.wave.2.fill" : "speaker.wave.1.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Channel Buttons

struct ChannelButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.3) : Color(white: 0.85)
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 55, height: 40)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 53, height: 38)
            
            Text(button == .channelUp ? "CH+" : "CH−")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Number Buttons

struct NumberButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.9)
    }
    
    var body: some View {
        ZStack {
            // Rounded square button
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            // Top highlight
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 48, height: 48)
            
            // Number
            Text(button.displayName)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.8))
                .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.8), radius: 0.5, x: 0, y: colorScheme == .dark ? 1 : -1)
        }
        .scaleEffect(isPressed ? 0.93 : 1.0)
        .offset(y: isPressed ? 2 : 0)
    }
}

// MARK: - Playback Buttons

struct PlaybackButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.28) : Color(white: 0.87)
    }
    
    private var iconName: String {
        switch button {
        case .play: return "play.fill"
        case .pause: return "pause.fill"
        case .stop: return "stop.fill"
        case .rewind: return "backward.fill"
        case .fastForward: return "forward.fill"
        default: return "questionmark"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 42, height: 42)
            
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
        }
        .scaleEffect(isPressed ? 0.93 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Mute Button

struct MuteButtonView: View {
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.28) : Color(white: 0.87)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 22
                    )
                )
                .frame(width: 48, height: 48)
            
            Image(systemName: "speaker.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
        }
        .scaleEffect(isPressed ? 0.93 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Generic Button

struct GenericButtonView: View {
    let button: RemoteButton
    let isPressed: Bool
    let colorScheme: ColorScheme
    
    private var buttonColor: Color {
        colorScheme == .dark ? Color(white: 0.28) : Color(white: 0.87)
    }
    
    private var iconName: String {
        switch button {
        case .home: return "house.fill"
        case .menu: return "line.3.horizontal"
        case .back: return "arrow.left"
        default: return "circle"
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [buttonColor, buttonColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 44)
                .shadow(color: .black.opacity(0.4), radius: isPressed ? 1 : 3, x: 0, y: isPressed ? 0 : 2)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 48, height: 42)
            
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white : .black.opacity(0.7))
        }
        .scaleEffect(isPressed ? 0.93 : 1.0)
        .offset(y: isPressed ? 1 : 0)
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeuomorphicButton(button: .power) {}
        HStack(spacing: 20) {
            SkeuomorphicButton(button: .volumeUp) {}
            SkeuomorphicButton(button: .volumeDown) {}
        }
        SkeuomorphicButton(button: .select) {}
        HStack {
            SkeuomorphicButton(button: .num1) {}
            SkeuomorphicButton(button: .num2) {}
            SkeuomorphicButton(button: .num3) {}
        }
    }
    .padding()
    .background(Color(white: 0.15))
}
