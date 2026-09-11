import SwiftUI
import SwiftData
import SelfwakeCore

struct WatchTodayView: View {
    @Query private var allSettings: [UserSettings]

    var body: some View {
        VStack(spacing: 6) {
            Text("Selfwake")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let target = allSettings.first?.targetTimeDefault {
                Text(target, style: .time)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            } else {
                Text("—")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }
            Text("hedef")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
