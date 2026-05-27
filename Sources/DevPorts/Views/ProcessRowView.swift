import SwiftUI
import AppKit

struct ProcessRowView: View {
    let process: DevProcess
    let onKill: () -> Void
    let onTerminal: () -> Void
    let onBrowser: () -> Void

    @State private var showKillConfirm = false
    @State private var copiedPort: UInt16?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: process.framework.iconName)
                    .foregroundStyle(process.framework.color)
                    .font(.title3)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(process.projectName)
                            .font(.headline)
                            .lineLimit(1)

                        Text(process.framework.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(verbatim: "PID \(process.pid)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    HStack(spacing: 6) {
                        ForEach(process.ports, id: \.self) { port in
                            Button {
                                copyURL(port: port)
                            } label: {
                                Text(verbatim: copiedPort == port ? "Copied!" : ":\(port)")
                                    .font(.caption)
                                    .fontDesign(.monospaced)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(copiedPort == port ? .green.opacity(0.15) : .blue.opacity(0.15))
                                    .foregroundStyle(copiedPort == port ? .green : .blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                            .help("Copy localhost:\(port)")
                        }

                        Text(process.displayPath)
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.head)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Button {
                        onBrowser()
                    } label: {
                        Image(systemName: "globe")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Open in Chrome")

                    Button {
                        onTerminal()
                    } label: {
                        Image(systemName: "terminal")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Open in Terminal")

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showKillConfirm = true
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.red)
                    .help("Kill process")
                }
            }
            .padding(.vertical, 4)

            if showKillConfirm {
                HStack(spacing: 8) {
                    Text(verbatim: "Kill \(process.projectName) on :\(process.portDisplay)?")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showKillConfirm = false
                        }
                    }
                    .controlSize(.small)

                    Button("Kill") {
                        onKill()
                        showKillConfirm = false
                    }
                    .controlSize(.small)
                    .tint(.red)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .background(.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func copyURL(port: UInt16) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("http://localhost:\(port)", forType: .string)
        copiedPort = port
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            if copiedPort == port { copiedPort = nil }
        }
    }
}
