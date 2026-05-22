import SwiftUI

struct SettingsView: View {
    @Bindable var monitor: ProcessMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)

            HStack {
                Text("Refresh interval")
                Spacer()
                Picker("", selection: Binding(
                    get: { monitor.refreshInterval },
                    set: { monitor.updateRefreshInterval($0) }
                )) {
                    ForEach(Constants.refreshIntervals, id: \.self) { interval in
                        Text("\(Int(interval))s").tag(interval)
                    }
                }
                .frame(width: 80)
            }
        }
        .padding()
        .frame(width: 280)
    }
}
