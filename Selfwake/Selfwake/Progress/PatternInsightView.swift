import SwiftUI
import SelfwakeCore

struct PatternInsightView: View {
    let successRate: Double?
    @State private var summary = "Yükleniyor…"

    var body: some View {
        Text(summary)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .task(id: successRate) {
                summary = await WeeklyPatternSummarizer(successRate: successRate).generate()
            }
    }
}
