import SwiftUI
import Charts
import SelfwakeCore

struct DriftChartView: View {
    let nights: [Night]

    private var series: [(date: Date, deviationMinutes: Double)] {
        ProgressStats.driftSeries(nights)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sapma")
                .font(.headline)
            if series.isEmpty {
                Text("Henüz veri yok.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Chart(series, id: \.date) { point in
                    LineMark(x: .value("Gece", point.date), y: .value("Sapma (dk)", point.deviationMinutes))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Gece", point.date), y: .value("Sapma (dk)", point.deviationMinutes))
                }
                .chartYAxisLabel("dakika")
                .frame(height: 160)
            }
        }
    }
}
