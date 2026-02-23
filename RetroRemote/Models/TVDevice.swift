import Foundation

/// Represents a discovered TV device on the network
struct TVDevice: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let ipAddress: String
    let port: Int
    let type: TVType
    let modelName: String?
    let serialNumber: String?
    var lastConnected: Date?
    
    init(id: UUID = UUID(), name: String, ipAddress: String, port: Int, type: TVType, modelName: String? = nil, serialNumber: String? = nil, lastConnected: Date? = nil) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.port = port
        self.type = type
        self.modelName = modelName
        self.serialNumber = serialNumber
        self.lastConnected = lastConnected
    }
}

/// Supported TV types
enum TVType: String, Codable, CaseIterable {
    case roku = "Roku"
    case samsung = "Samsung"
    case lg = "LG webOS"
    case appleTV = "Apple TV"
    case unknown = "Unknown"
    
    var icon: String {
        switch self {
        case .roku: return "tv"
        case .samsung: return "tv.fill"
        case .lg: return "tv.circle"
        case .appleTV: return "appletv"
        case .unknown: return "questionmark.circle"
        }
    }
    
    var defaultPort: Int {
        switch self {
        case .roku: return 8060
        case .samsung: return 8001
        case .lg: return 3000
        case .appleTV: return 7000
        case .unknown: return 0
        }
    }
}

/// Remote button types
enum RemoteButton: String, CaseIterable {
    // Navigation
    case up, down, left, right, select
    
    // Control
    case power, home, menu, back
    
    // Volume
    case volumeUp, volumeDown, mute
    
    // Channel
    case channelUp, channelDown
    
    // Playback
    case play, pause, stop, rewind, fastForward
    
    // Numbers
    case num0, num1, num2, num3, num4, num5, num6, num7, num8, num9
    
    var displayName: String {
        switch self {
        case .up: return "▲"
        case .down: return "▼"
        case .left: return "◀"
        case .right: return "▶"
        case .select: return "OK"
        case .power: return "⏻"
        case .home: return "⌂"
        case .menu: return "☰"
        case .back: return "←"
        case .volumeUp: return "+"
        case .volumeDown: return "−"
        case .mute: return "🔇"
        case .channelUp: return "CH+"
        case .channelDown: return "CH−"
        case .play: return "▶"
        case .pause: return "⏸"
        case .stop: return "⏹"
        case .rewind: return "⏪"
        case .fastForward: return "⏩"
        case .num0: return "0"
        case .num1: return "1"
        case .num2: return "2"
        case .num3: return "3"
        case .num4: return "4"
        case .num5: return "5"
        case .num6: return "6"
        case .num7: return "7"
        case .num8: return "8"
        case .num9: return "9"
        }
    }
    
    /// Returns the command string for each TV type
    func command(for tvType: TVType) -> String {
        switch tvType {
        case .roku:
            return rokuCommand
        case .samsung:
            return samsungCommand
        case .lg:
            return lgCommand
        case .appleTV:
            return appleTVCommand
        case .unknown:
            return ""
        }
    }
    
    private var rokuCommand: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        case .select: return "Select"
        case .power: return "Power"
        case .home: return "Home"
        case .menu: return "Info"
        case .back: return "Back"
        case .volumeUp: return "VolumeUp"
        case .volumeDown: return "VolumeDown"
        case .mute: return "VolumeMute"
        case .channelUp: return "ChannelUp"
        case .channelDown: return "ChannelDown"
        case .play: return "Play"
        case .pause: return "Pause"
        case .stop: return "Stop"
        case .rewind: return "Rev"
        case .fastForward: return "Fwd"
        case .num0: return "Lit_0"
        case .num1: return "Lit_1"
        case .num2: return "Lit_2"
        case .num3: return "Lit_3"
        case .num4: return "Lit_4"
        case .num5: return "Lit_5"
        case .num6: return "Lit_6"
        case .num7: return "Lit_7"
        case .num8: return "Lit_8"
        case .num9: return "Lit_9"
        }
    }
    
    private var samsungCommand: String {
        switch self {
        case .up: return "KEY_UP"
        case .down: return "KEY_DOWN"
        case .left: return "KEY_LEFT"
        case .right: return "KEY_RIGHT"
        case .select: return "KEY_ENTER"
        case .power: return "KEY_POWER"
        case .home: return "KEY_HOME"
        case .menu: return "KEY_MENU"
        case .back: return "KEY_RETURN"
        case .volumeUp: return "KEY_VOLUP"
        case .volumeDown: return "KEY_VOLDOWN"
        case .mute: return "KEY_MUTE"
        case .channelUp: return "KEY_CHUP"
        case .channelDown: return "KEY_CHDOWN"
        case .play: return "KEY_PLAY"
        case .pause: return "KEY_PAUSE"
        case .stop: return "KEY_STOP"
        case .rewind: return "KEY_REWIND"
        case .fastForward: return "KEY_FF"
        case .num0: return "KEY_0"
        case .num1: return "KEY_1"
        case .num2: return "KEY_2"
        case .num3: return "KEY_3"
        case .num4: return "KEY_4"
        case .num5: return "KEY_5"
        case .num6: return "KEY_6"
        case .num7: return "KEY_7"
        case .num8: return "KEY_8"
        case .num9: return "KEY_9"
        }
    }
    
    private var lgCommand: String {
        switch self {
        case .up: return "UP"
        case .down: return "DOWN"
        case .left: return "LEFT"
        case .right: return "RIGHT"
        case .select: return "ENTER"
        case .power: return "POWER"
        case .home: return "HOME"
        case .menu: return "MENU"
        case .back: return "BACK"
        case .volumeUp: return "VOLUMEUP"
        case .volumeDown: return "VOLUMEDOWN"
        case .mute: return "MUTE"
        case .channelUp: return "CHANNELUP"
        case .channelDown: return "CHANNELDOWN"
        case .play: return "PLAY"
        case .pause: return "PAUSE"
        case .stop: return "STOP"
        case .rewind: return "REWIND"
        case .fastForward: return "FASTFORWARD"
        case .num0: return "0"
        case .num1: return "1"
        case .num2: return "2"
        case .num3: return "3"
        case .num4: return "4"
        case .num5: return "5"
        case .num6: return "6"
        case .num7: return "7"
        case .num8: return "8"
        case .num9: return "9"
        }
    }
    
    private var appleTVCommand: String {
        switch self {
        case .up: return "up"
        case .down: return "down"
        case .left: return "left"
        case .right: return "right"
        case .select: return "select"
        case .power: return "suspend"
        case .home: return "home"
        case .menu: return "menu"
        case .back: return "menu"
        case .volumeUp: return "volumeup"
        case .volumeDown: return "volumedown"
        case .mute: return "mute"
        case .channelUp: return "channelup"
        case .channelDown: return "channeldown"
        case .play: return "play"
        case .pause: return "pause"
        case .stop: return "stop"
        case .rewind: return "rewind"
        case .fastForward: return "fastforward"
        case .num0, .num1, .num2, .num3, .num4, .num5, .num6, .num7, .num8, .num9:
            return String(displayName)
        }
    }
}
