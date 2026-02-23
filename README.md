# Retro Remote 📺🎮

A beautiful, skeuomorphic TV remote control app for iOS built with SwiftUI. Control your smart TV with a remote that looks and feels like the real thing!

![iOS 17.0+](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 🎨 Skeuomorphic Design
- **Realistic 3D buttons** with shadows, highlights, and depth
- **Press animations** that mimic real physical buttons
- **Brushed metal textures** and plastic button aesthetics
- **Beautiful gradients** for an authentic remote look
- **Dark and Light mode** support - looks great in both!

### 📡 Smart TV Discovery
- **Automatic discovery** of TVs on your local network using Bonjour/mDNS and SSDP
- **Supported platforms:**
  - **Roku** (ECP API)
  - **Samsung Smart TV** (WebSocket API)
  - **LG webOS** (SSAP protocol)
  - **Apple TV** (basic support)
- **Manual IP entry** for devices not automatically discovered
- **Remembers your last connected device**

### 🎛️ Full Remote Control
- **D-Pad Navigation** - Up, Down, Left, Right, OK/Select
- **Power button** with distinctive red styling
- **Volume controls** - Up, Down, Mute
- **Channel controls** - Up, Down
- **Playback controls** - Play, Pause, Stop, Rewind, Fast Forward
- **Navigation buttons** - Home, Menu, Back
- **Number pad** - 0-9 for direct channel input (toggle to show/hide)

### 📳 Haptic Feedback
- Different haptic intensities for different button types
- Power button: Heavy impact
- Select/Home/Menu: Medium impact
- Volume/Channel: Selection feedback
- Regular buttons: Light impact

## 📱 Screenshots

The app features a realistic remote control UI with:
- Metallic body with subtle textures
- 3D buttons with realistic shadows
- Smooth press animations
- Beautiful accent colors

## 🛠️ Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/haplollc/retro-remote.git
```

2. Open in Xcode:
```bash
cd retro-remote
open RetroRemote.xcodeproj
```

3. Build and run on your device or simulator

## 🔧 Setup

### Network Permissions
The app requires local network access to discover and control TVs. When prompted, allow the app to access your local network.

### TV Setup

#### Roku
- Ensure your Roku is on the same Wi-Fi network
- Enable "External Control Protocol" in Settings → System → Advanced system settings → External control → Network access

#### Samsung
- Enable remote control in TV settings
- The TV should be on the same network as your iOS device

#### LG webOS
- Enable "LG Connect Apps" on your TV
- Accept the pairing request when prompted

## 🏗️ Architecture

```
RetroRemote/
├── Models/
│   └── TVDevice.swift          # TV device model and remote button definitions
├── Services/
│   ├── NetworkDiscoveryService.swift  # Bonjour/SSDP discovery
│   └── TVControlService.swift         # TV control commands
├── Utilities/
│   └── HapticManager.swift     # Haptic feedback management
└── Views/
    ├── Components/
    │   ├── SkeuomorphicButton.swift   # Realistic button components
    │   └── DPadView.swift             # Direction pad component
    ├── RemoteControlView.swift        # Main remote UI
    └── DevicePickerView.swift         # TV selection screen
```

## 🧪 Testing

### Unit Tests
```bash
xcodebuild test -scheme RetroRemote -destination 'platform=iOS Simulator,name=iPhone 15'
```

Tests cover:
- Device model encoding/decoding
- Remote button commands for each TV type
- Device storage persistence
- Network discovery service

### UI Tests
- App launch verification
- Button existence checks
- Navigation flow tests
- Dark/Light mode screenshots

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by classic physical remote controls
- Built with love using SwiftUI
- Thanks to the open-source community for TV protocol documentation

---

Made with ❤️ by [Haplo LLC](https://github.com/haplollc)
