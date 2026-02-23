import SwiftUI

/// Windows 95 color palette and theming
struct Win95Theme {
    // Classic Windows colors
    static let silver = Color(red: 0.753, green: 0.753, blue: 0.753) // #C0C0C0
    static let darkGray = Color(red: 0.502, green: 0.502, blue: 0.502) // #808080
    static let lightGray = Color(red: 0.878, green: 0.878, blue: 0.878) // #E0E0E0
    static let white = Color.white
    static let black = Color.black
    
    // Title bar blue gradient
    static let titleBarBlue = Color(red: 0.0, green: 0.0, blue: 0.502) // #000080
    static let titleBarLightBlue = Color(red: 0.063, green: 0.094, blue: 0.627) // #1018A0
    
    // Button colors (keeping red for power, blue for OK)
    static let powerRed = Color(red: 0.75, green: 0.0, blue: 0.0)
    static let okBlue = Color(red: 0.0, green: 0.0, blue: 0.75)
    
    // Fonts - using monospaced for that retro feel
    static let pixelFont = Font.system(size: 12, weight: .bold, design: .monospaced)
    static let titleFont = Font.system(size: 14, weight: .bold, design: .monospaced)
    static let buttonFont = Font.system(size: 11, weight: .bold, design: .monospaced)
    
    // Beveled border styles for 3D effect
    struct BeveledBorder {
        let topLeft: Color
        let bottomRight: Color
        let innerTopLeft: Color
        let innerBottomRight: Color
    }
    
    static let raisedBorder = BeveledBorder(
        topLeft: white,
        bottomRight: black,
        innerTopLeft: lightGray,
        innerBottomRight: darkGray
    )
    
    static let pressedBorder = BeveledBorder(
        topLeft: black,
        bottomRight: white,
        innerTopLeft: darkGray,
        innerBottomRight: lightGray
    )
}

// MARK: - Beveled Rectangle Modifier

struct Win95BeveledRectangle: ViewModifier {
    let isPressed: Bool
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(Win95Theme.silver)
            .overlay(
                BeveledBorderView(isPressed: isPressed, cornerRadius: cornerRadius)
            )
    }
}

struct BeveledBorderView: View {
    let isPressed: Bool
    let cornerRadius: CGFloat
    
    var border: Win95Theme.BeveledBorder {
        isPressed ? Win95Theme.pressedBorder : Win95Theme.raisedBorder
    }
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            // Outer bevel
            Path { path in
                // Top edge (light when raised)
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
            }
            .stroke(border.topLeft, lineWidth: 2)
            
            Path { path in
                // Left edge (light when raised)
                path.move(to: CGPoint(x: 1, y: h))
                path.addLine(to: CGPoint(x: 1, y: 1))
            }
            .stroke(border.innerTopLeft, lineWidth: 1)
            
            Path { path in
                // Bottom edge (dark when raised)
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
            }
            .stroke(border.bottomRight, lineWidth: 2)
            
            Path { path in
                // Right inner edge
                path.move(to: CGPoint(x: w - 1, y: 1))
                path.addLine(to: CGPoint(x: w - 1, y: h - 1))
            }
            .stroke(border.innerBottomRight, lineWidth: 1)
        }
    }
}

// MARK: - Win95 Window Chrome

struct Win95WindowChrome<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            Win95TitleBar(title: title)
            
            // Content area with inner bevel (sunken)
            content
                .padding(4)
                .background(Win95Theme.silver)
                .overlay(
                    SunkenBorderView()
                        .padding(2)
                )
        }
        .background(Win95Theme.silver)
        .overlay(
            BeveledBorderView(isPressed: false, cornerRadius: 0)
        )
    }
}

struct Win95TitleBar: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Title with gradient background
            HStack(spacing: 6) {
                // App icon (pixelated remote)
                Win95PixelIcon(icon: .remote)
                    .frame(width: 16, height: 16)
                
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .background(
                LinearGradient(
                    colors: [Win95Theme.titleBarBlue, Win95Theme.titleBarLightBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Window controls
            HStack(spacing: 2) {
                Win95TitleButton(icon: "_")
                Win95TitleButton(icon: "□")
                Win95TitleButton(icon: "×")
            }
            .padding(.trailing, 3)
            .padding(.vertical, 3)
            .background(
                LinearGradient(
                    colors: [Win95Theme.titleBarBlue, Win95Theme.titleBarLightBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

struct Win95TitleButton: View {
    let icon: String
    @State private var isPressed = false
    
    var body: some View {
        Text(icon)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.black)
            .frame(width: 16, height: 14)
            .background(Win95Theme.silver)
            .overlay(
                BeveledBorderView(isPressed: isPressed, cornerRadius: 0)
            )
            .onTapGesture {
                // Decorative only
            }
    }
}

// MARK: - Sunken Border (for panels)

struct SunkenBorderView: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            // Top and left (dark - sunken)
            Path { path in
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
            }
            .stroke(Win95Theme.darkGray, lineWidth: 1)
            
            // Bottom and right (light - sunken)
            Path { path in
                path.move(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
            }
            .stroke(Win95Theme.white, lineWidth: 1)
        }
    }
}

// MARK: - Etched Divider

struct Win95EtchedDivider: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Win95Theme.darkGray)
                .frame(height: 1)
            Rectangle()
                .fill(Win95Theme.white)
                .frame(height: 1)
        }
    }
}

// MARK: - Pixel Art Icons

enum Win95IconType {
    case remote
    case power
    case speaker
    case speakerMute
    case channel
    case play
    case pause
    case stop
    case rewind
    case forward
    case home
    case menu
    case back
    case arrow
}

struct Win95PixelIcon: View {
    let icon: Win95IconType
    var color: Color = .black
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let pixelSize = size / 8
            
            Canvas { context, canvasSize in
                let pixels = pixelsFor(icon: icon)
                for pixel in pixels {
                    let rect = CGRect(
                        x: CGFloat(pixel.x) * pixelSize,
                        y: CGFloat(pixel.y) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
    
    struct Pixel {
        let x: Int
        let y: Int
    }
    
    func pixelsFor(icon: Win95IconType) -> [Pixel] {
        switch icon {
        case .remote:
            return [
                Pixel(x: 2, y: 0), Pixel(x: 3, y: 0), Pixel(x: 4, y: 0), Pixel(x: 5, y: 0),
                Pixel(x: 2, y: 1), Pixel(x: 5, y: 1),
                Pixel(x: 2, y: 2), Pixel(x: 3, y: 2), Pixel(x: 4, y: 2), Pixel(x: 5, y: 2),
                Pixel(x: 2, y: 3), Pixel(x: 5, y: 3),
                Pixel(x: 2, y: 4), Pixel(x: 5, y: 4),
                Pixel(x: 2, y: 5), Pixel(x: 5, y: 5),
                Pixel(x: 2, y: 6), Pixel(x: 3, y: 6), Pixel(x: 4, y: 6), Pixel(x: 5, y: 6),
                Pixel(x: 2, y: 7), Pixel(x: 3, y: 7), Pixel(x: 4, y: 7), Pixel(x: 5, y: 7)
            ]
        case .power:
            return [
                Pixel(x: 3, y: 0), Pixel(x: 4, y: 0),
                Pixel(x: 3, y: 1), Pixel(x: 4, y: 1),
                Pixel(x: 1, y: 2), Pixel(x: 3, y: 2), Pixel(x: 4, y: 2), Pixel(x: 6, y: 2),
                Pixel(x: 0, y: 3), Pixel(x: 7, y: 3),
                Pixel(x: 0, y: 4), Pixel(x: 7, y: 4),
                Pixel(x: 0, y: 5), Pixel(x: 7, y: 5),
                Pixel(x: 1, y: 6), Pixel(x: 6, y: 6),
                Pixel(x: 2, y: 7), Pixel(x: 3, y: 7), Pixel(x: 4, y: 7), Pixel(x: 5, y: 7)
            ]
        case .speaker:
            return [
                Pixel(x: 2, y: 2), Pixel(x: 3, y: 2),
                Pixel(x: 1, y: 3), Pixel(x: 2, y: 3), Pixel(x: 3, y: 3), Pixel(x: 4, y: 3), Pixel(x: 6, y: 3),
                Pixel(x: 1, y: 4), Pixel(x: 2, y: 4), Pixel(x: 3, y: 4), Pixel(x: 5, y: 4), Pixel(x: 7, y: 4),
                Pixel(x: 1, y: 5), Pixel(x: 2, y: 5), Pixel(x: 3, y: 5), Pixel(x: 4, y: 5), Pixel(x: 6, y: 5),
                Pixel(x: 2, y: 6), Pixel(x: 3, y: 6)
            ]
        case .play:
            return [
                Pixel(x: 2, y: 1),
                Pixel(x: 2, y: 2), Pixel(x: 3, y: 2),
                Pixel(x: 2, y: 3), Pixel(x: 3, y: 3), Pixel(x: 4, y: 3),
                Pixel(x: 2, y: 4), Pixel(x: 3, y: 4), Pixel(x: 4, y: 4), Pixel(x: 5, y: 4),
                Pixel(x: 2, y: 5), Pixel(x: 3, y: 5), Pixel(x: 4, y: 5),
                Pixel(x: 2, y: 6), Pixel(x: 3, y: 6),
                Pixel(x: 2, y: 7)
            ]
        default:
            return []
        }
    }
}

// MARK: - View Extension

extension View {
    func win95Beveled(isPressed: Bool = false, cornerRadius: CGFloat = 0) -> some View {
        self.modifier(Win95BeveledRectangle(isPressed: isPressed, cornerRadius: cornerRadius))
    }
}
