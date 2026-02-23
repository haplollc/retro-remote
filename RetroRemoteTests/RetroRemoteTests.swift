import XCTest
@testable import RetroRemote

final class RetroRemoteTests: XCTestCase {
    
    // MARK: - TVDevice Tests
    
    func testTVDeviceInitialization() throws {
        let device = TVDevice(
            name: "Test Roku",
            ipAddress: "192.168.1.100",
            port: 8060,
            type: .roku,
            modelName: "Roku Ultra"
        )
        
        XCTAssertEqual(device.name, "Test Roku")
        XCTAssertEqual(device.ipAddress, "192.168.1.100")
        XCTAssertEqual(device.port, 8060)
        XCTAssertEqual(device.type, .roku)
        XCTAssertEqual(device.modelName, "Roku Ultra")
    }
    
    func testTVTypeDefaultPorts() throws {
        XCTAssertEqual(TVType.roku.defaultPort, 8060)
        XCTAssertEqual(TVType.samsung.defaultPort, 8001)
        XCTAssertEqual(TVType.lg.defaultPort, 3000)
        XCTAssertEqual(TVType.appleTV.defaultPort, 7000)
    }
    
    func testTVTypeIcons() throws {
        XCTAssertEqual(TVType.roku.icon, "tv")
        XCTAssertEqual(TVType.samsung.icon, "tv.fill")
        XCTAssertEqual(TVType.lg.icon, "tv.circle")
        XCTAssertEqual(TVType.appleTV.icon, "appletv")
    }
    
    // MARK: - RemoteButton Tests
    
    func testRemoteButtonDisplayNames() throws {
        XCTAssertEqual(RemoteButton.power.displayName, "⏻")
        XCTAssertEqual(RemoteButton.select.displayName, "OK")
        XCTAssertEqual(RemoteButton.num5.displayName, "5")
        XCTAssertEqual(RemoteButton.volumeUp.displayName, "+")
    }
    
    func testRemoteButtonRokuCommands() throws {
        XCTAssertEqual(RemoteButton.up.command(for: .roku), "Up")
        XCTAssertEqual(RemoteButton.down.command(for: .roku), "Down")
        XCTAssertEqual(RemoteButton.select.command(for: .roku), "Select")
        XCTAssertEqual(RemoteButton.home.command(for: .roku), "Home")
        XCTAssertEqual(RemoteButton.volumeUp.command(for: .roku), "VolumeUp")
        XCTAssertEqual(RemoteButton.play.command(for: .roku), "Play")
    }
    
    func testRemoteButtonSamsungCommands() throws {
        XCTAssertEqual(RemoteButton.up.command(for: .samsung), "KEY_UP")
        XCTAssertEqual(RemoteButton.power.command(for: .samsung), "KEY_POWER")
        XCTAssertEqual(RemoteButton.mute.command(for: .samsung), "KEY_MUTE")
    }
    
    func testRemoteButtonLGCommands() throws {
        XCTAssertEqual(RemoteButton.up.command(for: .lg), "UP")
        XCTAssertEqual(RemoteButton.home.command(for: .lg), "HOME")
        XCTAssertEqual(RemoteButton.volumeDown.command(for: .lg), "VOLUMEDOWN")
    }
    
    // MARK: - DeviceStorage Tests
    
    func testDeviceStorageSaveAndLoad() throws {
        let storage = DeviceStorage()
        
        let device = TVDevice(
            name: "Test Samsung",
            ipAddress: "192.168.1.50",
            port: 8001,
            type: .samsung
        )
        
        storage.saveLastDevice(device)
        
        let loadedDevice = storage.loadLastDevice()
        XCTAssertNotNil(loadedDevice)
        XCTAssertEqual(loadedDevice?.name, device.name)
        XCTAssertEqual(loadedDevice?.ipAddress, device.ipAddress)
        XCTAssertEqual(loadedDevice?.type, device.type)
        
        // Cleanup
        storage.clearLastDevice()
    }
    
    func testDeviceStorageClear() throws {
        let storage = DeviceStorage()
        
        let device = TVDevice(
            name: "Test LG",
            ipAddress: "192.168.1.75",
            port: 3000,
            type: .lg
        )
        
        storage.saveLastDevice(device)
        storage.clearLastDevice()
        
        let loadedDevice = storage.loadLastDevice()
        XCTAssertNil(loadedDevice)
    }
    
    // MARK: - TVDevice Codable Tests
    
    func testTVDeviceEncodeDecode() throws {
        let device = TVDevice(
            name: "Encode Test",
            ipAddress: "10.0.0.1",
            port: 8060,
            type: .roku,
            modelName: "Ultra",
            serialNumber: "ABC123",
            lastConnected: Date()
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(device)
        
        let decoder = JSONDecoder()
        let decodedDevice = try decoder.decode(TVDevice.self, from: data)
        
        XCTAssertEqual(device.name, decodedDevice.name)
        XCTAssertEqual(device.ipAddress, decodedDevice.ipAddress)
        XCTAssertEqual(device.port, decodedDevice.port)
        XCTAssertEqual(device.type, decodedDevice.type)
        XCTAssertEqual(device.modelName, decodedDevice.modelName)
        XCTAssertEqual(device.serialNumber, decodedDevice.serialNumber)
    }
    
    // MARK: - Network Discovery Tests
    
    func testNetworkDiscoveryServiceInitialization() async throws {
        let service = await NetworkDiscoveryService()
        
        await MainActor.run {
            XCTAssertFalse(service.isScanning)
            XCTAssertTrue(service.discoveredDevices.isEmpty)
            XCTAssertNil(service.lastError)
        }
    }
    
    func testNetworkDiscoveryStartStop() async throws {
        let service = await NetworkDiscoveryService()
        
        await MainActor.run {
            service.startDiscovery()
            XCTAssertTrue(service.isScanning)
            
            service.stopDiscovery()
            XCTAssertFalse(service.isScanning)
        }
    }
    
    func testNetworkDiscoveryAddDevice() async throws {
        let service = await NetworkDiscoveryService()
        
        let device = TVDevice(
            name: "Mock TV",
            ipAddress: "192.168.1.200",
            port: 8060,
            type: .roku
        )
        
        await MainActor.run {
            service.addDevice(device)
            XCTAssertEqual(service.discoveredDevices.count, 1)
            XCTAssertEqual(service.discoveredDevices.first?.name, "Mock TV")
        }
    }
    
    func testNetworkDiscoveryNoDuplicates() async throws {
        let service = await NetworkDiscoveryService()
        
        let device1 = TVDevice(
            name: "TV 1",
            ipAddress: "192.168.1.100",
            port: 8060,
            type: .roku
        )
        
        let device2 = TVDevice(
            name: "TV 1 Renamed",
            ipAddress: "192.168.1.100",  // Same IP
            port: 8060,
            type: .roku
        )
        
        await MainActor.run {
            service.addDevice(device1)
            service.addDevice(device2)
            
            // Should not add duplicate
            XCTAssertEqual(service.discoveredDevices.count, 1)
        }
    }
    
    // MARK: - TV Control Service Tests
    
    func testTVControlServiceInitialization() async throws {
        let service = await TVControlService()
        
        await MainActor.run {
            XCTAssertFalse(service.isConnected)
            XCTAssertNil(service.lastError)
        }
    }
    
    func testTVControlServiceConnect() async throws {
        let service = await TVControlService()
        
        let device = TVDevice(
            name: "Test Device",
            ipAddress: "192.168.1.150",
            port: 8060,
            type: .roku
        )
        
        await MainActor.run {
            service.connect(to: device)
            
            XCTAssertTrue(service.isConnected)
            XCTAssertNotNil(service.connectedDevice)
            XCTAssertEqual(service.connectedDevice?.name, "Test Device")
            XCTAssertNotNil(service.connectedDevice?.lastConnected)
        }
    }
    
    func testTVControlServiceDisconnect() async throws {
        let service = await TVControlService()
        
        let device = TVDevice(
            name: "Test Device",
            ipAddress: "192.168.1.150",
            port: 8060,
            type: .roku
        )
        
        await MainActor.run {
            service.connect(to: device)
            service.disconnect()
            
            XCTAssertFalse(service.isConnected)
        }
    }
}
