import Foundation
import AppKit

enum ProcessActions {
    static func killProcess(pid: Int32) -> Bool {
        kill(pid, SIGTERM) == 0
    }

    static func openTerminal(at path: String) {
        let escapedPath = path
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Terminal"
            activate
            do script "cd \\\"\(escapedPath)\\\""
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
        }
    }

    static func openInFinder(at path: String) {
        NSWorkspace.shared.open(URL(fileURLWithPath: path))
    }

    static func openInChrome(port: UInt16) {
        guard let url = URL(string: "http://localhost:\(port)") else { return }
        if let chrome = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([url], withApplicationAt: chrome, configuration: config)
        } else {
            NSWorkspace.shared.open(url)
        }
    }
}
