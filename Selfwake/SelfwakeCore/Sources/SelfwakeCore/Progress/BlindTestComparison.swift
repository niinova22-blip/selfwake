import Foundation

/// Spec Bölüm 5: "İstatistik ekranı gerçek ve sahte gecelerin sapma ve
/// tepki süresi ortalamalarını karşılaştırır. Fark küçük çıkarsa uygulama
/// bunu gizlemez." Bu tip yalnızca sayıları üretir; gizleme/gösterme
/// kararı View'da değil — sayılar her zaman aynı şekilde hesaplanır.
public enum BlindTestComparison {
    public struct Result {
        public let realAverageAbsDeviationMinutes: Double?
        public let decoyAverageAbsDeviationMinutes: Double?
        public let realAverageReactionMs: Double?
        public let decoyAverageReactionMs: Double?
    }

    public static func compare(nights: [(night: Night, reaction: ReactionTest?)]) -> Result {
        let real = nights.filter { $0.night.isBlindTest && !$0.night.isBlindDecoy }
        let decoy = nights.filter { $0.night.isBlindDecoy }

        return Result(
            realAverageAbsDeviationMinutes: averageAbsDeviation(real.map(\.night)),
            decoyAverageAbsDeviationMinutes: averageAbsDeviation(decoy.map(\.night)),
            realAverageReactionMs: averageReaction(real.compactMap(\.reaction)),
            decoyAverageReactionMs: averageReaction(decoy.compactMap(\.reaction))
        )
    }

    private static func averageAbsDeviation(_ nights: [Night]) -> Double? {
        let values = nights.compactMap { $0.deviationMinutes.map { abs($0) } }
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func averageReaction(_ tests: [ReactionTest]) -> Double? {
        guard !tests.isEmpty else { return nil }
        return tests.map(\.averageMs).reduce(0, +) / Double(tests.count)
    }
}
