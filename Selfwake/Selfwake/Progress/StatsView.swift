import SwiftUI
import SwiftData
import SelfwakeCore

struct StatsView: View {
    @Query(sort: \Night.date, order: .reverse) private var nights: [Night]
    @Query private var allSettings: [UserSettings]
    @State private var showPaywall = false
    @State private var store = StoreKitManager()
    private var tier: SubscriptionTier { store.tier }

    private var successRate: Double? { ProgressStats.successRate(nights) }
    private var hasSilentWeek: Bool {
        ProgressStats.hasSilentWeekBadge(lastSevenNights: Array(nights.prefix(7)))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let rate = successRate {
                    Text("Başarı oranı: %\(Int(rate * 100))")
                        .font(.title3.bold())
                } else {
                    Text("Henüz veri yok")
                        .font(.title3.bold())
                }

                if hasSilentWeek {
                    Label("Ağın hiç çalmadığı bir hafta!", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }

                if PlusGate.isUnlocked(.driftCharts, tier: tier) {
                    DriftChartView(nights: nights)
                } else {
                    lockedCard("Sapma grafiği")
                }

                if PlusGate.isUnlocked(.aiComments, tier: tier) {
                    PatternInsightView(successRate: successRate)
                } else {
                    lockedCard("Haftalık desen özeti")
                }

                if PlusGate.isUnlocked(.blindTest, tier: tier), let settings = allSettings.first, settings.blindTestEnabled {
                    BlindTestComparisonView(result: blindTestResult)
                } else {
                    lockedCard("Kör test karşılaştırması")
                }
            }
            .padding(24)
        }
        .navigationTitle("İlerleme")
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .task { await store.refreshEntitlements() }
    }

    private var blindTestResult: BlindTestComparison.Result {
        BlindTestComparison.compare(nights: nights.map { ($0, nil) })
    }

    private func lockedCard(_ title: String) -> some View {
        Button {
            showPaywall = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.bold())
                    Text("Selfwake Plus ile açılır").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "lock.fill")
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
