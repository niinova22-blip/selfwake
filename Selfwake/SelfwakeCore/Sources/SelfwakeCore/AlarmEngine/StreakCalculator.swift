import Foundation

/// Spec Bölüm 4.4'teki kademeli geri çekilme: başarı arttıkça ağ hedef
/// saatten daha geç çalar ve daha kısık sesle çalar; asla tamamen susmaz
/// (Bölüm 4.2, "tamamen kapatılamaz").
public enum StreakTier: Int, CaseIterable {
    case tier0 = 0, tier1, tier2, tier3, tier4

    /// Ağın hedef saatten kaç dakika sonra çalacağı.
    public var alarmOffsetMinutes: Int { rawValue * 3 }

    /// 0.0-1.0, hiçbir kademede sıfır değildir.
    public var alarmVolumeLevel: Double {
        [1.0, 0.75, 0.5, 0.3, 0.15][rawValue]
    }
}

public enum StreakCalculator {
    /// Bir kademe ilerlemek için son 7 gecede en az bu kadar başarı gerekir.
    public static let advanceThreshold = 5
    /// Bunun altında bir kademe geriler; ikisi arası nötr bölgedir.
    public static let regressThreshold = 3

    /// Son 7 gecenin başarı dizisine bakıp bir sonraki kademeyi döner.
    /// Dizi 7 eleman değilse (yetersiz veri) kademe değişmez.
    public static func recompute(lastSevenNights successes: [Bool], currentTier: StreakTier) -> StreakTier {
        guard successes.count == 7 else { return currentTier }
        let successCount = successes.filter { $0 }.count

        if successCount >= advanceThreshold {
            let next = min(currentTier.rawValue + 1, StreakTier.allCases.count - 1)
            return StreakTier(rawValue: next)!
        }
        if successCount < regressThreshold {
            let next = max(currentTier.rawValue - 1, 0)
            return StreakTier(rawValue: next)!
        }
        return currentTier
    }
}
