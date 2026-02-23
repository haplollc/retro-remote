import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controlService: TVControlService
    
    var body: some View {
        Win95RemoteControlView(controlService: controlService)
    }
}

#Preview {
    ContentView()
        .environmentObject(TVControlService())
}
