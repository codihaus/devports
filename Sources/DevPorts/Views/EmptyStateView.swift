import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("No active dev servers")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Start Vite, Next.js, Bun, Python, Go...\nand DevPorts will detect them automatically.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
