import SwiftUI

/// The main remote control view with Windows 95/Minesweeper aesthetic
struct Win95RemoteControlView: View {
    @ObservedObject var controlService: TVControlService
    @State private var showingDevicePicker = false
    @State private var showNumberPad = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dithered/teal background (classic Windows desktop color)
                Win95DesktopBackground()
                    .ignoresSafeArea()
                
                // Main window
                VStack(spacing: 0) {
                    // Title bar
                    Win95TitleBar(title: "Retro Remote")
                    
                    // Menu bar
                    Win95MenuBar(
                        isConnected: controlService.isConnected,
                        deviceName: controlService.connectedDevice?.name ?? "No Device"
                    ) {
                        showingDevicePicker = true
                    }
                    
                    // Content area with beveled sunken border
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            // Power section
                            Win95GroupBox(title: "Power") {
                                Win95Button(button: .power) {
                                    sendCommand(.power)
                                }
                            }
                            
                            // Navigation section
                            Win95GroupBox(title: "Navigation") {
                                VStack(spacing: 12) {
                                    // Top row: Home, Menu, Back
                                    HStack(spacing: 16) {
                                        Win95Button(button: .back) {
                                            sendCommand(.back)
                                        }
                                        Win95Button(button: .home) {
                                            sendCommand(.home)
                                        }
                                        Win95Button(button: .menu) {
                                            sendCommand(.menu)
                                        }
                                    }
                                    
                                    // D-Pad
                                    Win95DPadView { button in
                                        sendCommand(button)
                                    }
                                }
                            }
                            
                            // Volume & Channel section
                            HStack(spacing: 12) {
                                Win95GroupBox(title: "Volume") {
                                    VStack(spacing: 8) {
                                        Win95Button(button: .volumeUp) {
                                            sendCommand(.volumeUp)
                                        }
                                        Win95Button(button: .mute) {
                                            sendCommand(.mute)
                                        }
                                        Win95Button(button: .volumeDown) {
                                            sendCommand(.volumeDown)
                                        }
                                    }
                                }
                                
                                Win95GroupBox(title: "Channel") {
                                    VStack(spacing: 8) {
                                        Win95Button(button: .channelUp) {
                                            sendCommand(.channelUp)
                                        }
                                        Spacer()
                                            .frame(height: 46)
                                        Win95Button(button: .channelDown) {
                                            sendCommand(.channelDown)
                                        }
                                    }
                                }
                            }
                            
                            // Playback section
                            Win95GroupBox(title: "Playback") {
                                HStack(spacing: 8) {
                                    Win95Button(button: .rewind) {
                                        sendCommand(.rewind)
                                    }
                                    Win95Button(button: .play) {
                                        sendCommand(.play)
                                    }
                                    Win95Button(button: .pause) {
                                        sendCommand(.pause)
                                    }
                                    Win95Button(button: .stop) {
                                        sendCommand(.stop)
                                    }
                                    Win95Button(button: .fastForward) {
                                        sendCommand(.fastForward)
                                    }
                                }
                            }
                            
                            // Number pad toggle
                            Win95ToggleButton(
                                title: showNumberPad ? "Hide Numbers" : "Show Numbers",
                                isOn: showNumberPad
                            ) {
                                withAnimation(.none) {
                                    showNumberPad.toggle()
                                }
                                HapticManager.shared.lightTap()
                            }
                            
                            // Number pad (if showing)
                            if showNumberPad {
                                Win95GroupBox(title: "Numbers") {
                                    VStack(spacing: 8) {
                                        HStack(spacing: 8) {
                                            Win95Button(button: .num1) { sendCommand(.num1) }
                                            Win95Button(button: .num2) { sendCommand(.num2) }
                                            Win95Button(button: .num3) { sendCommand(.num3) }
                                        }
                                        HStack(spacing: 8) {
                                            Win95Button(button: .num4) { sendCommand(.num4) }
                                            Win95Button(button: .num5) { sendCommand(.num5) }
                                            Win95Button(button: .num6) { sendCommand(.num6) }
                                        }
                                        HStack(spacing: 8) {
                                            Win95Button(button: .num7) { sendCommand(.num7) }
                                            Win95Button(button: .num8) { sendCommand(.num8) }
                                            Win95Button(button: .num9) { sendCommand(.num9) }
                                        }
                                        HStack(spacing: 8) {
                                            Spacer()
                                            Win95Button(button: .num0) { sendCommand(.num0) }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            
                            // Status bar style footer
                            Win95StatusBar(
                                status: controlService.isConnected ? "Connected" : "Disconnected"
                            )
                        }
                        .padding(8)
                    }
                    .background(Win95Theme.silver)
                    .overlay(
                        SunkenBorderView()
                            .padding(3)
                    )
                }
                .background(Win95Theme.silver)
                .overlay(
                    BeveledBorderView(isPressed: false, cornerRadius: 0)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, geometry.safeAreaInsets.top > 0 ? 8 : 20)
            }
        }
        .sheet(isPresented: $showingDevicePicker) {
            DevicePickerView(controlService: controlService)
        }
    }
    
    private func sendCommand(_ button: RemoteButton) {
        Task {
            _ = await controlService.sendCommand(button)
        }
    }
}

// MARK: - Win95 Desktop Background

struct Win95DesktopBackground: View {
    // Classic teal Windows 95 desktop color
    let desktopTeal = Color(red: 0.0, green: 0.5, blue: 0.5)
    
    var body: some View {
        // Dithered pattern simulation
        Canvas { context, size in
            // Base teal
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(desktopTeal))
            
            // Add subtle dither pattern
            for x in stride(from: 0, to: size.width, by: 2) {
                for y in stride(from: 0, to: size.height, by: 2) {
                    if (Int(x) + Int(y)) % 4 == 0 {
                        let rect = CGRect(x: x, y: y, width: 1, height: 1)
                        context.fill(Path(rect), with: .color(desktopTeal.opacity(0.8)))
                    }
                }
            }
        }
    }
}

// MARK: - Win95 Menu Bar

struct Win95MenuBar: View {
    let isConnected: Bool
    let deviceName: String
    let onDeviceSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Win95MenuButton(title: "File") { }
            Win95MenuButton(title: "Device") {
                onDeviceSelect()
            }
            Win95MenuButton(title: "Help") { }
            
            Spacer()
            
            // Connection indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(deviceName)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Win95Theme.silver)
            .overlay(
                SunkenBorderView()
            )
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Win95Theme.silver)
    }
}

struct Win95MenuButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(isPressed ? Win95Theme.darkGray : Win95Theme.silver)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Win95 Group Box

struct Win95GroupBox<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title positioned over the border
            ZStack(alignment: .topLeading) {
                // Etched border
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Win95Theme.darkGray, lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Win95Theme.white, lineWidth: 1)
                            .offset(x: 1, y: 1)
                    )
                    .padding(.top, 8)
                
                // Title label with background to break the border
                Text(" \(title) ")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.black)
                    .background(Win95Theme.silver)
                    .padding(.leading, 10)
            }
            
            // Content
            content
                .padding(12)
                .padding(.top, 4)
        }
    }
}

// MARK: - Win95 Toggle Button

struct Win95ToggleButton: View {
    let title: String
    let isOn: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Checkbox
                ZStack {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 13, height: 13)
                        .overlay(
                            SunkenBorderView()
                        )
                    
                    if isOn {
                        Text("✓")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                
                Text(title)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Win95Theme.silver)
            .overlay(
                BeveledBorderView(isPressed: isPressed, cornerRadius: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Win95 Status Bar

struct Win95StatusBar: View {
    let status: String
    
    var body: some View {
        HStack {
            Text(status)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.black)
            Spacer()
            Text("Retro Remote v1.0")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Win95Theme.darkGray)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Win95Theme.silver)
        .overlay(
            SunkenBorderView()
        )
    }
}

#Preview {
    Win95RemoteControlView(controlService: TVControlService())
}
