import Foundation

/// Sabah Özeti ekranının (spec Bölüm 5) sayısal karşılaştırmaları —
/// hedef/gerçek saat ve sapma zaten `Night`'ta; burada yalnızca
/// dünle-bugünü kıyaslayan hesaplar.
public enum MorningSummary {
    /// Bugünün ortalama tepki süresinden dünkünü çıkarır. Negatif = bugün
    /// daha hızlı. Dün veri yoksa (ilk gece ya da test atlanmış) nil.
    public static func reactionTimeDeltaMs(today: ReactionTest, yesterday: ReactionTest?) -> Double? {
        guard let yesterday, !yesterday.timestampsMs.isEmpty else { return nil }
        return today.averageMs - yesterday.averageMs
    }
}
