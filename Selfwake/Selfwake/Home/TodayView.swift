import SwiftUI
import SelfwakeCore

struct TodayView: View {
    @State private var targetTime = Calendar.current.date(
        bySettingHour: 7, minute: 0, second: 0, of: .now
    ) ?? .now
    @State private var showRitual = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Bu geceki hedef")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(targetTime, style: .time)
                .font(.system(size: 56, weight: .bold, design: .rounded))

            Button("Gece Ritüelini Başlat") {
                showRitual = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fullScreenCover(isPresented: $showRitual) {
            RitualFlowView(targetTime: targetTime)
        }
    }
}

#Preview {
    TodayView()
}
