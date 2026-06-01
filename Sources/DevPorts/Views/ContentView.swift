import SwiftUI

@MainActor
struct ContentView: View {
    @Bindable var monitor: ProcessMonitor
    @State private var showSettings = false
    @State private var copiedAll = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 420)
        .onAppear { monitor.startAutoRefresh() }
        .onDisappear { monitor.stopAutoRefresh() }
    }

    private var header: some View {
        HStack {
            Text("DevPorts")
                .font(.headline)

            Spacer()

            if monitor.isScanning {
                ProgressView()
                    .controlSize(.small)
            }

            Button {
                let count = monitor.copyAllURLs()
                if count > 0 {
                    copiedAll = true
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        copiedAll = false
                    }
                }
            } label: {
                Image(systemName: copiedAll ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .help("Copy all URLs")
            .disabled(monitor.processes.isEmpty)

            Button {
                monitor.scan()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.borderless)
            .help("Refresh")

            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(.borderless)
            .popover(isPresented: $showSettings) {
                SettingsView(monitor: monitor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var content: some View {
        if monitor.processes.isEmpty && !monitor.isScanning {
            EmptyStateView()
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(monitor.processes) { process in
                        ProcessRowView(
                            process: process,
                            onKill: { _ = monitor.killProcess(process) },
                            onTerminal: { monitor.openTerminal(for: process) },
                            onBrowser: { monitor.openInBrowser(process) }
                        )
                        .padding(.horizontal, 16)

                        if process.id != monitor.processes.last?.id {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: NSScreen.main.map { $0.visibleFrame.height * 0.8 } ?? 600)
        }
    }

    private var footer: some View {
        HStack {
            Text(verbatim: "\(monitor.processCount) process\(monitor.processCount == 1 ? "" : "es")")
                .font(.caption)
                .foregroundStyle(.secondary)

            if monitor.isAutoRefreshActive {
                Text(verbatim: "Auto-refresh: \(Int(monitor.refreshInterval))s")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
