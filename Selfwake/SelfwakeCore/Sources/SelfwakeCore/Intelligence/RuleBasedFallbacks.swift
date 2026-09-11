import Foundation

/// Model kullanılamıyorsa (eski cihaz, Apple Intelligence kapalı) her
/// üretici sessizce buraya düşer. Bu dosya asla başarısız olmaz — hiçbir
/// harici çağrı yapmaz, yalnızca şablon doldurur.
public enum RuleBasedFallbacks {
    public static func intentSentence(targetTime: Date, firstEventTitle: String?) -> String {
        let time = targetTime.formatted(date: .omitted, time: .shortened)
        if let title = firstEventTitle {
            return "Yarın \(title) var — \(time)'te ayakta ol."
        }
        return "Yarın \(time)'te ayaktasın."
    }

    public static func morningComment(deviationMinutes: Double?) -> String {
        guard let deviation = deviationMinutes else {
            return "Bu sabah henüz bir ölçüm yok."
        }
        if abs(deviation) <= 10 {
            return "Hedefe çok yakındın."
        }
        return deviation > 0
            ? "Hedeften \(Int(deviation)) dakika geç uyandın."
            : "Hedeften \(Int(-deviation)) dakika erken uyandın."
    }

    public static func weeklyPatternSummary(successRate: Double?) -> String {
        guard let rate = successRate else { return "Henüz yeterli veri yok." }
        return "Bu hafta gecelerin %\(Int(rate * 100))'i hedefin ±30 dakikası içindeydi."
    }

    public static func journalThemes(notes: [String]) -> String {
        notes.isEmpty ? "Henüz not eklenmedi." : "Son notlarında tekrar eden bir tema henüz görülmüyor."
    }

    public static func adaptiveTargetTimeSuggestion(recentDeviationsMinutes: [Double]) -> String? {
        guard recentDeviationsMinutes.count >= 5 else { return nil }
        let average = recentDeviationsMinutes.reduce(0, +) / Double(recentDeviationsMinutes.count)
        guard average > 10 else { return nil }
        return "Son gecelerde ortalama \(Int(average)) dakika geç uyanıyorsun — hedefini \(Int(average)) dakika öne almayı dene."
    }

    public static func eveningRiskWarning(bedTimeDeltaMinutes: Double?) -> String? {
        guard let delta = bedTimeDeltaMinutes, delta > 30 else { return nil }
        return "Her zamankinden geç yatıyorsun — bu gece güvenlik ağının çalma ihtimali yüksek."
    }

    public static func toneNeutral(_ base: String) -> String { base }
}
