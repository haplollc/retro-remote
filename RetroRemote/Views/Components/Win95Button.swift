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

// MARK: - Consistent Button Size Constants

struct Win95ButtonSizes {
    static let standardWidth: CGFloat = 50
    static let standardHeight: CGFloat = 36
    static let dpadArrowSize: CGFloat = 40
    static let okButtonSize: CGFloat = 44
    static let playbackWidth: CGFloat = 44
    static let playbackHeight: CGFloat = 36
    static let navButtonWidth: CGFloat = 50
    static let navButtonHeight: CGFloat = 36
    static let numberButtonSize: CGFloat = 44
}

// MARK: - Consistent Arrow Shape

struct TriangleArrow: Shape {
    enum Direction {
        case up, down, left, right
    }
    
    let direction: Direction
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let size = min(rect.width, rect.height)
        let inset: CGFloat = size * 0.15
        
        switch direction {
        case .up:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY + inset))
            path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
            path.closeSubpath()
        case .down:
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY - inset))
            path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
            path.closeSubpath()
        case .left:
            path.move(to: CGPoint(x: rect.minX + inset, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
            path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
            path.closeSubpath()
        case .right:
            path.move(to: CGPoint(x: rect.maxX - inset, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
            path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - Double Arrow for Playback

struct DoubleTriangleArrow: View {
    let direction: TriangleArrow.Direction
    let size: CGFloat
    
    var body: some View {
        HStack(spacing: -2) {
            TriangleArrow(direction: direction)
                .fill(Color.black)
                .frame(width: size, height: size)
            TriangleArrow(direction: direction)
                .fill(Color.black)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Power Button

struct Win95PowerButton: View {
    let isPressed: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white, lineWidth: 2)
                .frame(width: 18, height: 18)
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: 10)
                .offset(y: -2)
        }
        .frame(width: 52, height: 52)
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

// MARK: - Select/OK Button

struct Win95SelectButton: View {
    let isPressed: Bool
    
    var body: some View {
        ZStack {
            Text("OK")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(width: Win95ButtonSizes.okButtonSize, height: Win95ButtonSizes.okButtonSize)
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

// MARK: - Directional Button

struct Win95DirectionalButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    private var arrowDirection: TriangleArrow.Direction {
        switch button {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        default: return .up
        }
    }
    
    var body: some View {
        TriangleArrow(direction: arrowDirection)
            .fill(Color.black)
            .frame(width: 14, height: 14)
            .frame(width: Win95ButtonSizes.dpadArrowSize, height: Win95ButtonSizes.dpadArrowSize)
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
        Text(button == .volumeUp ? "VOL+" : "VOL−")
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: Win95ButtonSizes.standardWidth, height: Win95ButtonSizes.standardHeight)
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
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: Win95ButtonSizes.standardWidth, height: Win95ButtonSizes.standardHeight)
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
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: Win95ButtonSizes.numberButtonSize, height: Win95ButtonSizes.numberButtonSize)
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
    
    var body: some View {
        ZStack {
            playbackIcon
        }
        .frame(width: Win95ButtonSizes.playbackWidth, height: Win95ButtonSizes.playbackHeight)
        .background(Win95Theme.silver)
        .overlay(
            Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
        )
        .offset(y: isPressed ? 1 : 0)
    }
    
    @ViewBuilder
    private var playbackIcon: some View {
        switch button {
        case .play:
            TriangleArrow(direction: .right)
                .fill(Color.black)
                .frame(width: 12, height: 12)
        case .pause:
            HStack(spacing: 3) {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4, height: 12)
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4, height: 12)
            }
        case .stop:
            Rectangle()
                .fill(Color.black)
                .frame(width: 10, height: 10)
        case .rewind:
            DoubleTriangleArrow(direction: .left, size: 8)
        case .fastForward:
            DoubleTriangleArrow(direction: .right, size: 8)
        default:
            EmptyView()
        }
    }
}

// MARK: - Mute Button

struct Win95MuteButton: View {
    let isPressed: Bool
    
    var body: some View {
        Text("MUTE")
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: Win95ButtonSizes.standardWidth, height: Win95ButtonSizes.standardHeight)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Generic Button (Back, Home, Menu)

struct Win95GenericButton: View {
    let button: RemoteButton
    let isPressed: Bool
    
    private var labelText: String {
        switch button {
        case .home: return "HOME"
        case .menu: return "MENU"
        case .back: return "BACK"
        default: return "•"
        }
    }
    
    var body: some View {
        Text(labelText)
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: Win95ButtonSizes.navButtonWidth, height: Win95ButtonSizes.navButtonHeight)
            .background(Win95Theme.silver)
            .overlay(
                Win95ButtonBevel(isPressed: isPressed, baseColor: Win95Theme.silver)
            )
            .offset(y: isPressed ? 1 : 0)
    }
}

// MARK: - Guide Button (new for Channel section)

struct Win95GuideButton: View {
    let isPressed: Bool
    let action: () -> Void
    
    @State private var pressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.none) { pressed = true }
            HapticManager.shared.lightTap()
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.none) { pressed = false }
            }
        }) {
            Text("GUIDE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(width: Win95ButtonSizes.standardWidth, height: Win95ButtonSizes.standardHeight)
                .background(Win95Theme.silver)
                .overlay(
                    Win95ButtonBevel(isPressed: pressed, baseColor: Win95Theme.silver)
                )
                .offset(y: pressed ? 1 : 0)
        }
        .buttonStyle(PlainButtonStyle())
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
