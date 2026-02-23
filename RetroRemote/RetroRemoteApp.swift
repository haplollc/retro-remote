import SwiftUI

@main
struct RetroRemoteApp: App {
    @StateObject private var controlService = TVControlService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controlService)
        }
    }
}
