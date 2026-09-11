import Foundation

/// Bölüm 8.1: Ana Ekran'da, ritüel akışının *dışında* gösterilen tek
/// cümlelik uyarı kartı. Saf eşik mantığı yeterli.
public enum EveningRiskWarningGenerator {
    public static func warning(bedTimeDeltaMinutes: Double?) -> String? {
        RuleBasedFallbacks.eveningRiskWarning(bedTimeDeltaMinutes: bedTimeDeltaMinutes)
    }
}
