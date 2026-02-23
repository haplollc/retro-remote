import Foundation
import Network
import Combine

/// Protocol for TV discovery implementations
protocol TVDiscoveryProtocol {
    func startDiscovery()
    func stopDiscovery()
    var discoveredDevices: [TVDevice] { get }
}

/// Main service for discovering smart TVs on the local network
@MainActor
class NetworkDiscoveryService: NSObject, ObservableObject {
    @Published var discoveredDevices: [TVDevice] = []
    @Published var isScanning = false
    @Published var lastError: String?
    
    private var bonjourBrowser: NWBrowser?
    private var ssdpDiscovery: SSDPDiscovery?
    private var discoveryTask: Task<Void, Never>?
    
    // Service types for mDNS/Bonjour discovery
    private let serviceTypes = [
        "_roku._tcp.",      // Roku devices
        "_samsung._tcp.",   // Samsung TVs
        "_airplay._tcp.",   // Apple TV
        "_lgssdp._tcp.",    // LG webOS
        "_webos._tcp."      // LG webOS alternative
    ]
    
    override init() {
        super.init()
        ssdpDiscovery = SSDPDiscovery(delegate: self)
    }
    
    /// Start scanning for all supported TV types
    func startDiscovery() {
        guard !isScanning else { return }
        
        isScanning = true
        discoveredDevices.removeAll()
        lastError = nil
        
        // Start Bonjour/mDNS discovery
        startBonjourDiscovery()
        
        // Start SSDP discovery for Roku and other UPnP devices
        ssdpDiscovery?.startDiscovery()
        
        // Auto-stop after 30 seconds
        discoveryTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            await MainActor.run {
                self.stopDiscovery()
            }
        }
    }
    
    /// Stop all discovery processes
    func stopDiscovery() {
        isScanning = false
        
        bonjourBrowser?.cancel()
        bonjourBrowser = nil
        
        ssdpDiscovery?.stopDiscovery()
        
        discoveryTask?.cancel()
        discoveryTask = nil
    }
    
    /// Add a device if not already discovered
    func addDevice(_ device: TVDevice) {
        if !discoveredDevices.contains(where: { $0.ipAddress == device.ipAddress }) {
            discoveredDevices.append(device)
        }
    }
    
    // MARK: - Bonjour Discovery
    
    private func startBonjourDiscovery() {
        for serviceType in serviceTypes {
            let browser = NWBrowser(for: .bonjour(type: serviceType, domain: "local."), using: .tcp)
            
            browser.stateUpdateHandler = { [weak self] state in
                switch state {
                case .failed(let error):
                    Task { @MainActor in
                        self?.lastError = "Bonjour error: \(error.localizedDescription)"
                    }
                default:
                    break
                }
            }
            
            browser.browseResultsChangedHandler = { [weak self] results, changes in
                Task { @MainActor in
                    for result in results {
                        self?.handleBonjourResult(result, serviceType: serviceType)
                    }
                }
            }
            
            browser.start(queue: .main)
        }
    }
    
    private func handleBonjourResult(_ result: NWBrowser.Result, serviceType: String) {
        guard case let .service(name, type, domain, _) = result.endpoint else { return }
        
        let tvType = determineTVType(from: type)
        
        // Resolve the service to get IP address
        let connection = NWConnection(to: result.endpoint, using: .tcp)
        connection.stateUpdateHandler = { [weak self] state in
            if case .ready = state {
                if let endpoint = connection.currentPath?.remoteEndpoint,
                   case let .hostPort(host, port) = endpoint {
                    let ipAddress = host.debugDescription
                    let device = TVDevice(
                        name: name,
                        ipAddress: ipAddress,
                        port: Int(port.rawValue),
                        type: tvType,
                        modelName: nil
                    )
                    Task { @MainActor in
                        self?.addDevice(device)
                    }
                }
                connection.cancel()
            }
        }
        connection.start(queue: .global())
    }
    
    private func determineTVType(from serviceType: String) -> TVType {
        if serviceType.contains("roku") {
            return .roku
        } else if serviceType.contains("samsung") {
            return .samsung
        } else if serviceType.contains("lg") || serviceType.contains("webos") {
            return .lg
        } else if serviceType.contains("airplay") {
            return .appleTV
        }
        return .unknown
    }
}

// MARK: - SSDP Discovery Delegate

extension NetworkDiscoveryService: SSDPDiscoveryDelegate {
    nonisolated func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscover device: TVDevice) {
        Task { @MainActor in
            self.addDevice(device)
        }
    }
    
    nonisolated func ssdpDiscovery(_ discovery: SSDPDiscovery, didFailWithError error: String) {
        Task { @MainActor in
            self.lastError = error
        }
    }
}

// MARK: - SSDP Discovery

protocol SSDPDiscoveryDelegate: AnyObject {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscover device: TVDevice)
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFailWithError error: String)
}

/// SSDP/UPnP discovery for Roku and similar devices
class SSDPDiscovery {
    weak var delegate: SSDPDiscoveryDelegate?
    
    private var udpSocket: NWConnection?
    private let multicastGroup = "239.255.255.250"
    private let ssdpPort: UInt16 = 1900
    private var isRunning = false
    private var discoveryTask: Task<Void, Never>?
    
    // SSDP search targets
    private let searchTargets = [
        "roku:ecp",                           // Roku ECP
        "urn:dial-multiscreen-org:service:dial:1",  // DIAL (Samsung, LG)
        "urn:schemas-upnp-org:device:MediaRenderer:1"
    ]
    
    init(delegate: SSDPDiscoveryDelegate? = nil) {
        self.delegate = delegate
    }
    
    func startDiscovery() {
        guard !isRunning else { return }
        isRunning = true
        
        for searchTarget in searchTargets {
            sendSSDPSearch(searchTarget: searchTarget)
        }
    }
    
    func stopDiscovery() {
        isRunning = false
        udpSocket?.cancel()
        udpSocket = nil
        discoveryTask?.cancel()
        discoveryTask = nil
    }
    
    private func sendSSDPSearch(searchTarget: String) {
        let message = """
        M-SEARCH * HTTP/1.1\r
        HOST: \(multicastGroup):\(ssdpPort)\r
        MAN: "ssdp:discover"\r
        MX: 3\r
        ST: \(searchTarget)\r
        \r
        
        """
        
        guard let data = message.data(using: .utf8) else { return }
        
        // Create UDP connection to multicast group
        let host = NWEndpoint.Host(multicastGroup)
        let port = NWEndpoint.Port(rawValue: ssdpPort)!
        let endpoint = NWEndpoint.hostPort(host: host, port: port)
        
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        
        let connection = NWConnection(to: endpoint, using: params)
        
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                connection.send(content: data, completion: .contentProcessed { error in
                    if error == nil {
                        self?.receiveResponses(on: connection)
                    }
                })
            case .failed(let error):
                self?.delegate?.ssdpDiscovery(self!, didFailWithError: "SSDP error: \(error.localizedDescription)")
            default:
                break
            }
        }
        
        connection.start(queue: .global())
        
        // Keep connection alive for responses
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            connection.cancel()
        }
    }
    
    private func receiveResponses(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self, self.isRunning else { return }
            
            if let data = data, let response = String(data: data, encoding: .utf8) {
                self.parseSSDP(response: response)
            }
            
            if !isComplete && error == nil {
                self.receiveResponses(on: connection)
            }
        }
    }
    
    private func parseSSDP(response: String) {
        var headers: [String: String] = [:]
        
        for line in response.components(separatedBy: "\r\n") {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespaces).uppercased()
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                headers[key] = value
            }
        }
        
        guard let location = headers["LOCATION"],
              let url = URL(string: location),
              let host = url.host else {
            return
        }
        
        let port = url.port ?? 80
        
        // Determine TV type from response
        var tvType: TVType = .unknown
        var name = "Unknown TV"
        
        if let st = headers["ST"]?.lowercased() {
            if st.contains("roku") {
                tvType = .roku
                name = "Roku Device"
            } else if st.contains("dial") {
                // Could be Samsung or LG
                if let server = headers["SERVER"]?.lowercased() {
                    if server.contains("samsung") {
                        tvType = .samsung
                        name = "Samsung TV"
                    } else if server.contains("lg") || server.contains("webos") {
                        tvType = .lg
                        name = "LG TV"
                    }
                }
            }
        }
        
        // Try to get friendly name from USN
        if let usn = headers["USN"] {
            if usn.contains("Roku") {
                tvType = .roku
                name = "Roku Device"
            }
        }
        
        let device = TVDevice(
            name: name,
            ipAddress: host,
            port: port,
            type: tvType
        )
        
        delegate?.ssdpDiscovery(self, didDiscover: device)
    }
}
