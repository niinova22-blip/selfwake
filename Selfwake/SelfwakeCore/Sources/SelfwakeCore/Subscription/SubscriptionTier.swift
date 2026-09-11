import Foundation

/// Spec'in para modeli: "Gece ritüeli ve güvenlik ağı sonsuza kadar
/// ücretsiz. Plus katmanı ölçümü açar." Reklam yok — Selfwake'in tek
/// gelir kalemi abonelik.
public enum SubscriptionTier: String, Codable {
    case free, plus
}

public enum PlusFeature: CaseIterable {
    case unlimitedReactionHistory
    case driftCharts
    case variableAnalysis
    case blindTest
    case aiComments
}

public enum PlusGate {
    /// Ücretsiz kademede tutulan gece sayısı — bunun ötesi Plus gerektirir.
    /// Ürün kararı taslak; App Store Connect'te kesinleşince güncellenecek.
    public static let freeHistoryDays = 7

    public static func isUnlocked(_ feature: PlusFeature, tier: SubscriptionTier) -> Bool {
        tier == .plus
    }
}
