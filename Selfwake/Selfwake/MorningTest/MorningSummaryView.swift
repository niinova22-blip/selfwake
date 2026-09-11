import SwiftUI
import SelfwakeCore

struct MorningSummaryView: View {
    let night: Night
    let todayReaction: ReactionTest
    let yesterdayReaction: ReactionTest?
    let onDone: () -> Void

    @State private var comment = "Yükleniyor…"

    private var delta: Double? {
        MorningSummary.reactionTimeDeltaMs(today: todayReaction, yesterday: yesterdayReaction)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Sabah özeti")
                .font(.title2.bold())

            row("Hedef saat", night.targetTime.formatted(date: .omitted, time: .shortened))
            row("Gerçek uyanma", night.actualWakeTime?.formatted(date: .omitted, time: .shortened) ?? "—")
            row("Sapma", night.deviationMinutes.map { "\(Int($0)) dk" } ?? "—")
            row("Tepki süresi", "\(Int(todayReaction.averageMs)) ms")
            if let delta {
                row("Dünle fark", "\(delta > 0 ? "+" : "")\(Int(delta)) ms")
            }

            Text(comment)
                .font(.footnote)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Button("Devam et", action: onDone)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .task {
            comment = await MorningCommentGenerator(
                deviationMinutes: night.deviationMinutes,
                reactionDeltaMs: delta,
                bedTimeText: night.bedTime?.formatted(date: .omitted, time: .shortened)
            ).generate()
        }
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold).font(.system(.body, design: .rounded))
        }
    }
}
