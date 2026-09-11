import SwiftUI
import SelfwakeCore

/// Spec Bölüm 5: fark küçük çıkarsa gizlemez — sayılar her zaman aynı
/// şekilde hesaplanıp gösterilir.
struct BlindTestComparisonView: View {
    let result: BlindTestComparison.Result

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kör test karşılaştırması")
                .font(.headline)
            row("Sapma (ort. |dk|)", result.realAverageAbsDeviationMinutes, result.decoyAverageAbsDeviationMinutes)
            row("Tepki süresi (ort. ms)", result.realAverageReactionMs, result.decoyAverageReactionMs)
        }
    }

    private func row(_ title: String, _ real: Double?, _ decoy: Double?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            HStack {
                labeled("Gerçek", real)
                Spacer()
                labeled("Sahte", decoy)
            }
        }
    }

    private func labeled(_ label: String, _ value: Double?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value.map { String(format: "%.0f", $0) } ?? "—")
                .font(.system(.body, design: .rounded)).bold()
        }
    }
}
