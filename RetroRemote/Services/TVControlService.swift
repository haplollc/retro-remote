import Foundation
import Combine

/// Service for controlling connected TV devices
@MainActor
class TVControlService: ObservableObject {
    @Published var connectedDevice: TVDevice?
    @Published var isConnected = false
    @Published var lastError: String?
    
    private var webSocket: URLSessionWebSocketTask?
    private let session = URLSession.shared
    private let deviceStorage = DeviceStorage()
    
    init() {
        // Load last connected device on init
        if let lastDevice = deviceStorage.loadLastDevice() {
            connectedDevice = lastDevice
        }
    }
    
    /// Connect to a TV device
    func connect(to device: TVDevice) {
        var updatedDevice = device
        updatedDevice.lastConnected = Date()
        
        connectedDevice = updatedDevice
        isConnected = true
        lastError = nil
        
        // Save as last connected device
        deviceStorage.saveLastDevice(updatedDevice)
        
        // Establish WebSocket for Samsung TVs
        if device.type == .samsung {
            connectSamsungWebSocket(device: device)
        }
    }
    
    /// Disconnect from current device
    func disconnect() {
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        isConnected = false
    }
    
    /// Send a button press command to the connected TV
    func sendCommand(_ button: RemoteButton) async -> Bool {
        guard let device = connectedDevice else {
            lastError = "No device connected"
            return false
        }
        
        switch device.type {
        case .roku:
            return await sendRokuCommand(button, to: device)
        case .samsung:
            return await sendSamsungCommand(button, to: device)
        case .lg:
            return await sendLGCommand(button, to: device)
        case .appleTV:
            return await sendAppleTVCommand(button, to: device)
        case .unknown:
            lastError = "Unknown device type"
            return false
        }
    }
    
    // MARK: - Roku ECP API
    
    private func sendRokuCommand(_ button: RemoteButton, to device: TVDevice) async -> Bool {
        let command = button.command(for: .roku)
        let urlString = "http://\(device.ipAddress):\(device.port)/keypress/\(command)"
        
        guard let url = URL(string: urlString) else {
            lastError = "Invalid URL"
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        
        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            lastError = "Network error: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Samsung WebSocket API
    
    private func connectSamsungWebSocket(device: TVDevice) {
        let urlString = "ws://\(device.ipAddress):\(device.port)/api/v2/channels/samsung.remote.control"
        guard let url = URL(string: urlString) else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
    
    private func sendSamsungCommand(_ button: RemoteButton, to device: TVDevice) async -> Bool {
        if webSocket == nil {
            // Try to establish connection first
            connectSamsungWebSocket(device: device)
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard webSocket != nil else {
                lastError = "Failed to connect to Samsung TV"
                return false
            }
        }
        
        let command = button.command(for: .samsung)
        let payload: [String: Any] = [
            "method": "ms.remote.control",
            "params": [
                "Cmd": "Click",
                "DataOfCmd": command,
                "Option": "false",
                "TypeOfRemote": "SendRemoteKey"
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            lastError = "Failed to encode command"
            return false
        }
        
        do {
            try await webSocket?.send(.string(jsonString))
            return true
        } catch {
            lastError = "Failed to send command: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - LG webOS SSAP Protocol
    
    private func sendLGCommand(_ button: RemoteButton, to device: TVDevice) async -> Bool {
        // LG webOS uses WebSocket with SSAP protocol
        let urlString = "ws://\(device.ipAddress):\(device.port)"
        guard let url = URL(string: urlString) else {
            lastError = "Invalid URL"
            return false
        }
        
        let command = button.command(for: .lg)
        let payload: [String: Any] = [
            "type": "button",
            "name": command
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            lastError = "Failed to encode command"
            return false
        }
        
        // For LG, we use a simpler HTTP-based approach as fallback
        let httpUrl = "http://\(device.ipAddress):8080/roap/api/command"
        guard let httpURL = URL(string: httpUrl) else {
            return false
        }
        
        var request = URLRequest(url: httpURL)
        request.httpMethod = "POST"
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = """
        <?xml version="1.0" encoding="utf-8"?>
        <command>
            <name>\(command)</name>
        </command>
        """.data(using: .utf8)
        
        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            // WebSocket fallback
            return await sendViaWebSocket(jsonString, to: url)
        }
    }
    
    // MARK: - Apple TV
    
    private func sendAppleTVCommand(_ button: RemoteButton, to device: TVDevice) async -> Bool {
        // Apple TV control typically requires pairing and uses DACP/DAAP protocol
        // This is a simplified implementation
        let command = button.command(for: .appleTV)
        let urlString = "http://\(device.ipAddress):\(device.port)/ctrl-int/1/\(command)"
        
        guard let url = URL(string: urlString) else {
            lastError = "Invalid URL"
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 5
        
        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200 || httpResponse.statusCode == 204
            }
            return false
        } catch {
            lastError = "Apple TV error: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Helpers
    
    private func sendViaWebSocket(_ message: String, to url: URL) async -> Bool {
        let task = session.webSocketTask(with: url)
        task.resume()
        
        do {
            try await task.send(.string(message))
            task.cancel(with: .normalClosure, reason: nil)
            return true
        } catch {
            lastError = "WebSocket error: \(error.localizedDescription)"
            task.cancel(with: .abnormalClosure, reason: nil)
            return false
        }
    }
}

// MARK: - Device Storage

/// Handles persisting device information
class DeviceStorage {
    private let lastDeviceKey = "lastConnectedDevice"
    private let defaults = UserDefaults.standard
    
    func saveLastDevice(_ device: TVDevice) {
        if let encoded = try? JSONEncoder().encode(device) {
            defaults.set(encoded, forKey: lastDeviceKey)
        }
    }
    
    func loadLastDevice() -> TVDevice? {
        guard let data = defaults.data(forKey: lastDeviceKey),
              let device = try? JSONDecoder().decode(TVDevice.self, from: data) else {
            return nil
        }
        return device
    }
    
    func clearLastDevice() {
        defaults.removeObject(forKey: lastDeviceKey)
    }
}
