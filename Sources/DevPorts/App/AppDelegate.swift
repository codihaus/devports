import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidResignActive(_ notification: Notification) {
        for window in NSApp.windows where window is NSPanel {
            window.close()
        }
    }
}
