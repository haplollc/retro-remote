import SwiftUI

/// The main remote control view with skeuomorphic design
struct RemoteControlView: View {
    @ObservedObject var controlService: TVControlService
    @Environment(\.colorScheme) var colorScheme
    @State private var showingDevicePicker = false
    @State private var showNumberPad = false
    
    // Remote body colors
    private var remoteBodyGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.18),
                    Color(red: 0.1, green: 0.1, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.92, blue: 0.94),
                    Color(red: 0.85, green: 0.85, blue: 0.87),
                    Color(red: 0.8, green: 0.8, blue: 0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                // Remote body
                VStack(spacing: 0) {
                    // Header with device info and settings
                    headerView
                        .padding(.top, 10)
                    
                    // Main remote content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Power button section
                            powerSection
                            
                            // D-pad section
                            dPadSection
                            
                            // Volume and Channel section
                            volumeChannelSection
                            
                            // Playback controls
                            playbackSection
                            
                            // Number pad toggle
                            if showNumberPad {
                                numberPadSection
                                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            }
                            
                            // Toggle number pad button
                            numberPadToggle
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                    }
                }
                .background(
                    remoteBodyShape
                )
                .padding(.horizontal, 20)
                .padding(.vertical, geometry.safeAreaInsets.top > 0 ? 0 : 20)
            }
        }
        .sheet(isPresented: $showingDevicePicker) {
            DevicePickerView(controlService: controlService)
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(white: 0.05), Color(white: 0.1)]
                : [Color(white: 0.85), Color(white: 0.95)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Remote Body Shape
    
    private var remoteBodyShape: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(remoteBodyGradient)
            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            .overlay(
                // Edge highlight
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Device indicator
            Button(action: { showingDevicePicker = true }) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(controlService.isConnected ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                        .shadow(color: controlService.isConnected ? .green.opacity(0.5) : .clear, radius: 3)
                    
                    Text(controlService.connectedDevice?.name ?? "No Device")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                )
            }
            
            Spacer()
            
            // Settings/Device picker
            Button(action: { showingDevicePicker = true }) {
                Image(systemName: "tv.and.mediabox")
                    .font(.system(size: 18))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.6))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    )
            }
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Power Section
    
    private var powerSection: some View {
        HStack {
            Spacer()
            SkeuomorphicButton(button: .power) {
                sendCommand(.power)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - D-Pad Section
    
    private var dPadSection: some View {
        VStack(spacing: 15) {
            // Top row: Home, Menu, Back
            HStack(spacing: 25) {
                SkeuomorphicButton(button: .back) {
                    sendCommand(.back)
                }
                SkeuomorphicButton(button: .home) {
                    sendCommand(.home)
                }
                SkeuomorphicButton(button: .menu) {
                    sendCommand(.menu)
                }
            }
            
            // D-Pad
            DPadView { button in
                sendCommand(button)
            }
        }
    }
    
    // MARK: - Volume & Channel Section
    
    private var volumeChannelSection: some View {
        HStack(spacing: 40) {
            // Volume
            VStack(spacing: 15) {
                SkeuomorphicButton(button: .volumeUp) {
                    sendCommand(.volumeUp)
                }
                
                SkeuomorphicButton(button: .mute) {
                    sendCommand(.mute)
                }
                
                SkeuomorphicButton(button: .volumeDown) {
                    sendCommand(.volumeDown)
                }
            }
            
            // Channel
            VStack(spacing: 15) {
                SkeuomorphicButton(button: .channelUp) {
                    sendCommand(.channelUp)
                }
                
                Spacer()
                    .frame(height: 50)
                
                SkeuomorphicButton(button: .channelDown) {
                    sendCommand(.channelDown)
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Playback Section
    
    private var playbackSection: some View {
        VStack(spacing: 15) {
            // Playback label
            Text("PLAYBACK")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                .tracking(2)
            
            HStack(spacing: 20) {
                SkeuomorphicButton(button: .rewind) {
                    sendCommand(.rewind)
                }
                SkeuomorphicButton(button: .play) {
                    sendCommand(.play)
                }
                SkeuomorphicButton(button: .pause) {
                    sendCommand(.pause)
                }
                SkeuomorphicButton(button: .stop) {
                    sendCommand(.stop)
                }
                SkeuomorphicButton(button: .fastForward) {
                    sendCommand(.fastForward)
                }
            }
        }
    }
    
    // MARK: - Number Pad
    
    private var numberPadSection: some View {
        VStack(spacing: 12) {
            // Number pad label
            Text("NUMBERS")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.4))
                .tracking(2)
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    SkeuomorphicButton(button: .num1) { sendCommand(.num1) }
                    SkeuomorphicButton(button: .num2) { sendCommand(.num2) }
                    SkeuomorphicButton(button: .num3) { sendCommand(.num3) }
                }
                HStack(spacing: 10) {
                    SkeuomorphicButton(button: .num4) { sendCommand(.num4) }
                    SkeuomorphicButton(button: .num5) { sendCommand(.num5) }
                    SkeuomorphicButton(button: .num6) { sendCommand(.num6) }
                }
                HStack(spacing: 10) {
                    SkeuomorphicButton(button: .num7) { sendCommand(.num7) }
                    SkeuomorphicButton(button: .num8) { sendCommand(.num8) }
                    SkeuomorphicButton(button: .num9) { sendCommand(.num9) }
                }
                HStack(spacing: 10) {
                    Spacer()
                    SkeuomorphicButton(button: .num0) { sendCommand(.num0) }
                    Spacer()
                }
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Number Pad Toggle
    
    private var numberPadToggle: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showNumberPad.toggle()
            }
            HapticManager.shared.lightTap()
        }) {
            HStack {
                Image(systemName: showNumberPad ? "number.circle.fill" : "number.circle")
                    .font(.system(size: 16))
                Text(showNumberPad ? "Hide Numbers" : "Show Numbers")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.5))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
            )
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func sendCommand(_ button: RemoteButton) {
        Task {
            _ = await controlService.sendCommand(button)
        }
    }
}

#Preview {
    RemoteControlView(controlService: TVControlService())
}
