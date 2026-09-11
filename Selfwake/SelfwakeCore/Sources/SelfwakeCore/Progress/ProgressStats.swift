import Foundation

/// İlerleme ekranının (spec Bölüm 5) temel sayısal hesapları.
public enum ProgressStats {
    /// Değerlendirilebilir (uyanılmış) gecelerin başarı oranı. Hiç
    /// değerlendirilebilir gece yoksa nil.
    public static func successRate(_ nights: [Night]) -> Double? {
        let evaluated = nights.compactMap(\.isSuccess)
        guard !evaluated.isEmpty else { return nil }
        return Double(evaluated.filter { $0 }.count) / Double(evaluated.count)
    }

    /// Spec Bölüm 4.4: art arda 7 gece `alarmDidRing == false` olması
    /// "ağın hiç çalmadığı bir hafta" rozetini tetikler. Dizi tam 7
    /// elemanlı değilse (eksik veri) rozet verilmez.
    public static func hasSilentWeekBadge(lastSevenNights nights: [Night]) -> Bool {
        guard nights.count == 7 else { return false }
        return nights.allSatisfy { !$0.alarmDidRing }
    }

    /// Sapma grafiği (Swift Charts) için ham veri — yalnızca uyanılmış
    /// geceler dahil.
    public static func driftSeries(_ nights: [Night]) -> [(date: Date, deviationMinutes: Double)] {
        nights.compactMap { night in
            guard let deviation = night.deviationMinutes else { return nil }
            return (night.date, deviation)
        }
    }
}
