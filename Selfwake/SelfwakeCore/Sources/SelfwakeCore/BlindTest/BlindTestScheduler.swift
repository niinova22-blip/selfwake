import Foundation

/// Spec Bölüm 5, "Kör test gecesi": `UserSettings.blindTestEnabled`
/// açıkken bazı geceler niyet protokolü yerine boş bekleme ekranı gelir.
/// Rastgelelik burada üretilmiyor — çağıran taraf (Ana Ekran/AppRouter)
/// `Double.random(in: 0..<1)` üretip parametre olarak veriyor, böylece bu
/// tip tamamen deterministik test edilebiliyor.
public enum BlindTestScheduler {
    /// Kör test açıkken bir gecenin "kapsama girme" olasılığı.
    public static let inclusionProbability = 0.3
    /// Kapsama giren bir gecenin sahte (boş bekleme) olma olasılığı.
    public static let decoyProbability = 0.5

    public struct Assignment: Equatable {
        public let isBlindTest: Bool
        public let isBlindDecoy: Bool
    }

    public static func assign(
        blindTestEnabled: Bool,
        inclusionRoll: Double,
        decoyRoll: Double
    ) -> Assignment {
        guard blindTestEnabled, inclusionRoll < inclusionProbability else {
            return Assignment(isBlindTest: false, isBlindDecoy: false)
        }
        let isDecoy = decoyRoll < decoyProbability
        return Assignment(isBlindTest: true, isBlindDecoy: isDecoy)
    }
}
