import SwiftUI

@main
struct DevPortsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var monitor = ProcessMonitor()

    var body: some Scene {
        MenuBarExtra {
            ContentView(monitor: monitor)
                .onAppear { monitor.startBackgroundRefresh() }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "network")
                if monitor.processCount > 0 {
                    Text(verbatim: "\(monitor.processCount)")
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
