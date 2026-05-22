import Foundation
import SwiftUI
import AppKit

@MainActor
@Observable
final class ProcessMonitor {
    var processes: [DevProcess] = []
    var isScanning = false
    var error: String?

    private var backgroundTimer: Timer?
    private var foregroundTimer: Timer?
    private(set) var isAutoRefreshActive = false

    @ObservationIgnored
    @AppStorage("refreshInterval") var refreshInterval: Double = Constants.defaultRefreshInterval

    @ObservationIgnored
    private let backgroundInterval: Double = 10.0

    var processCount: Int { processes.count }

    func startBackgroundRefresh() {
        scanAsync()
        backgroundTimer?.invalidate()
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: backgroundInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard self?.isAutoRefreshActive != true else { return }
                self?.scanAsync()
            }
        }
    }

    func scan() {
        isScanning = true
        error = nil
        processes = ProcessScanner.scan()
        isScanning = false
    }

    func scanAsync() {
        guard !isScanning else { return }
        isScanning = true
        error = nil
        Task.detached {
            let result = ProcessScanner.scan()
            await MainActor.run { [weak self] in
                self?.processes = result
                self?.isScanning = false
            }
        }
    }

    func startAutoRefresh() {
        guard !isAutoRefreshActive else { return }
        isAutoRefreshActive = true
        scanAsync()
        scheduleForegroundTimer()
    }

    func stopAutoRefresh() {
        isAutoRefreshActive = false
        foregroundTimer?.invalidate()
        foregroundTimer = nil
    }

    func updateRefreshInterval(_ interval: Double) {
        refreshInterval = interval
        if isAutoRefreshActive {
            foregroundTimer?.invalidate()
            scheduleForegroundTimer()
        }
    }

    func killProcess(_ process: DevProcess) -> Bool {
        let success = ProcessActions.killProcess(pid: process.pid)
        if success {
            processes.removeAll { $0.pid == process.pid }
        }
        return success
    }

    func openTerminal(for process: DevProcess) {
        ProcessActions.openTerminal(at: process.workingDirectory)
    }

    func openInBrowser(_ process: DevProcess) {
        guard let port = process.ports.first else { return }
        ProcessActions.openInChrome(port: port)
    }

    func copyAllURLs() -> Int {
        let urls = processes.flatMap { process in
            process.ports.map { "http://localhost:\($0)" }
        }
        guard !urls.isEmpty else { return 0 }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(urls.joined(separator: "\n"), forType: .string)
        return urls.count
    }

    private func scheduleForegroundTimer() {
        foregroundTimer?.invalidate()
        foregroundTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.scanAsync()
            }
        }
    }
}
