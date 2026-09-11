import Testing
@testable import SelfwakeCore

@Suite("StreakCalculator kademe geçişleri")
struct StreakCalculatorTests {
    @Test("5/7 başarı bir kademe ilerletir")
    func advancesOnFiveOfSeven() {
        let successes = [true, true, true, true, true, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier1)
        #expect(next == .tier2)
    }

    @Test("En üst kademede daha fazla ilerlemez")
    func staysAtTopTier() {
        let successes = Array(repeating: true, count: 7)
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier4)
        #expect(next == .tier4)
    }

    @Test("2/7 başarı bir kademe geriletir")
    func regressesOnLowSuccess() {
        let successes = [true, true, false, false, false, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier2)
        #expect(next == .tier1)
    }

    @Test("En alt kademede sıfırın altına inmez")
    func neverBelowZero() {
        let successes = Array(repeating: false, count: 7)
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier0)
        #expect(next == .tier0)
    }

    @Test("3/7 ile 4/7 arası nötr bölgede kademe değişmez")
    func neutralZoneNoChange() {
        let successes = [true, true, true, false, false, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier2)
        #expect(next == .tier2)
    }

    @Test("Eksik veri (7'den az gece) kademeyi değiştirmez")
    func incompleteDataNoChange() {
        let next = StreakCalculator.recompute(lastSevenNights: [true, true], currentTier: .tier2)
        #expect(next == .tier2)
    }

    @Test("Hiçbir kademede ses seviyesi sıfır değildir")
    func volumeNeverZero() {
        for tier in StreakTier.allCases {
            #expect(tier.alarmVolumeLevel > 0)
        }
    }

    @Test("Kademe yükseldikçe offset artar, ses azalır")
    func tiersAreMonotonic() {
        let tiers = StreakTier.allCases.sorted { $0.rawValue < $1.rawValue }
        for (a, b) in zip(tiers, tiers.dropFirst()) {
            #expect(a.alarmOffsetMinutes < b.alarmOffsetMinutes)
            #expect(a.alarmVolumeLevel > b.alarmVolumeLevel)
        }
    }
}
