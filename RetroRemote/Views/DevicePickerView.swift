import SwiftUI

/// Device picker view for discovering and selecting TVs
struct DevicePickerView: View {
    @ObservedObject var controlService: TVControlService
    @StateObject private var discoveryService = NetworkDiscoveryService()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Scanning indicator
                    if discoveryService.isScanning {
                        scanningIndicator
                    }
                    
                    // Device list
                    if discoveryService.discoveredDevices.isEmpty && !discoveryService.isScanning {
                        emptyStateView
                    } else {
                        deviceList
                    }
                    
                    // Manual IP entry section
                    manualEntrySection
                }
            }
            .navigationTitle("Select TV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if discoveryService.isScanning {
                            discoveryService.stopDiscovery()
                        } else {
                            discoveryService.startDiscovery()
                        }
                    }) {
                        if discoveryService.isScanning {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .onAppear {
                discoveryService.startDiscovery()
            }
            .onDisappear {
                discoveryService.stopDiscovery()
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.95)
    }
    
    // MARK: - Scanning Indicator
    
    private var scanningIndicator: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(colorScheme == .dark ? .white : .blue)
            
            Text("Scanning for TVs...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            colorScheme == .dark
                ? Color.blue.opacity(0.2)
                : Color.blue.opacity(0.1)
        )
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tv.slash")
                .font(.system(size: 60))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.3) : .black.opacity(0.3))
            
            Text("No TVs Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
            
            Text("Make sure your TV is on and connected to the same Wi-Fi network.")
                .font(.system(size: 14))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                discoveryService.startDiscovery()
            }) {
                Label("Scan Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    // MARK: - Device List
    
    private var deviceList: some View {
        List {
            Section {
                ForEach(discoveryService.discoveredDevices) { device in
                    DeviceRow(device: device, isConnected: device.id == controlService.connectedDevice?.id) {
                        controlService.connect(to: device)
                        HapticManager.shared.success()
                        dismiss()
                    }
                }
            } header: {
                Text("Discovered Devices")
                    .font(.system(size: 12, weight: .semibold))
            }
            
            // Show last connected device if not in discovered list
            if let lastDevice = controlService.connectedDevice,
               !discoveryService.discoveredDevices.contains(where: { $0.id == lastDevice.id }) {
                Section {
                    DeviceRow(device: lastDevice, isConnected: true) {
                        controlService.connect(to: lastDevice)
                        dismiss()
                    }
                } header: {
                    Text("Last Connected")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Manual Entry
    
    @State private var manualIP = ""
    @State private var selectedType: TVType = .roku
    @State private var showManualEntry = false
    
    private var manualEntrySection: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button(action: {
                withAnimation {
                    showManualEntry.toggle()
                }
            }) {
                HStack {
                    Image(systemName: showManualEntry ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Enter IP Manually")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.blue)
                .padding()
            }
            
            if showManualEntry {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("IP Address", text: $manualIP)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Picker("Type", selection: $selectedType) {
                            ForEach(TVType.allCases.filter { $0 != .unknown }, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Button(action: connectManual) {
                        Text("Connect")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(manualIP.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(manualIP.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(colorScheme == .dark ? Color(white: 0.15) : Color.white)
    }
    
    private func connectManual() {
        let device = TVDevice(
            name: "\(selectedType.rawValue) (\(manualIP))",
            ipAddress: manualIP,
            port: selectedType.defaultPort,
            type: selectedType
        )
        controlService.connect(to: device)
        HapticManager.shared.success()
        dismiss()
    }
}

// MARK: - Device Row

struct DeviceRow: View {
    let device: TVDevice
    let isConnected: Bool
    let onSelect: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 15) {
                // TV Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    iconColor.opacity(0.8),
                                    iconColor.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: device.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                // Device info
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    HStack(spacing: 6) {
                        Text(device.type.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(device.ipAddress)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Connected indicator
                if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var iconColor: Color {
        switch device.type {
        case .roku: return .purple
        case .samsung: return .blue
        case .lg: return .red
        case .appleTV: return .gray
        case .unknown: return .secondary
        }
    }
}

#Preview {
    DevicePickerView(controlService: TVControlService())
}
