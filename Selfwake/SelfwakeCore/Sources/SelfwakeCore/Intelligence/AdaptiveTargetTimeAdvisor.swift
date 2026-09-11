import Foundation

/// Bölüm 8.1: yalnızca öneri, hedefi asla otomatik değiştirmez. Saf
/// matematik yeterli — dil modeli gerekmiyor, `RuleBasedFallbacks`
/// tek kaynak.
public enum AdaptiveTargetTimeAdvisor {
    public static func suggestion(recentDeviationsMinutes: [Double]) -> String? {
        RuleBasedFallbacks.adaptiveTargetTimeSuggestion(recentDeviationsMinutes: recentDeviationsMinutes)
    }
}
