import Testing
import Foundation
@testable import SelfwakeCore

@Suite("ProgressStats")
struct ProgressStatsTests {
    private func night(deviationMinutes: Double?, alarmDidRing: Bool = false, date: Date = .now) -> Night {
        let target = Date(timeIntervalSince1970: 0)
        let actual = deviationMinutes.map { target.addingTimeInterval($0 * 60) }
        return Night(date: date, targetTime: target, actualWakeTime: actual, alarmDidRing: alarmDidRing)
    }

    @Test("Değerlendirilebilir gece yoksa başarı oranı nil")
    func successRateNilWhenNoData() {
        let nights = [night(deviationMinutes: nil)]
        #expect(ProgressStats.successRate(nights) == nil)
    }

    @Test("Başarı oranı doğru hesaplanır")
    func successRateComputed() {
        let nights = [
            night(deviationMinutes: 10),  // başarı
            night(deviationMinutes: 20),  // başarı
            night(deviationMinutes: 40),  // başarısız
            night(deviationMinutes: nil)  // sayılmaz
        ]
        #expect(ProgressStats.successRate(nights) == 2.0 / 3.0)
    }

    @Test("7'den az gecede sessiz hafta rozeti verilmez")
    func noBadgeWithFewerThanSevenNights() {
        let nights = Array(repeating: night(deviationMinutes: 0, alarmDidRing: false), count: 6)
        #expect(!ProgressStats.hasSilentWeekBadge(lastSevenNights: nights))
    }

    @Test("7 gece hiç alarm çalmadıysa rozet verilir")
    func badgeWhenSevenSilentNights() {
        let nights = Array(repeating: night(deviationMinutes: 0, alarmDidRing: false), count: 7)
        #expect(ProgressStats.hasSilentWeekBadge(lastSevenNights: nights))
    }

    @Test("7 geceden biri bile çaldıysa rozet verilmez")
    func noBadgeIfOneNightRang() {
        var nights = Array(repeating: night(deviationMinutes: 0, alarmDidRing: false), count: 6)
        nights.append(night(deviationMinutes: 0, alarmDidRing: true))
        #expect(!ProgressStats.hasSilentWeekBadge(lastSevenNights: nights))
    }

    @Test("Sapma serisi yalnızca uyanılmış geceleri içerir")
    func driftSeriesExcludesUnwoken() {
        let nights = [night(deviationMinutes: 15), night(deviationMinutes: nil)]
        let series = ProgressStats.driftSeries(nights)
        #expect(series.count == 1)
        #expect(series[0].deviationMinutes == 15)
    }
}
