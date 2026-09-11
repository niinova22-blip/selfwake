import Testing
import Foundation
@testable import SelfwakeCore

@Suite("BlindTestComparison")
struct BlindTestComparisonTests {
    private func night(deviation: Double, isBlindTest: Bool, isBlindDecoy: Bool) -> Night {
        let target = Date(timeIntervalSince1970: 0)
        let actual = target.addingTimeInterval(deviation * 60)
        return Night(date: .now, targetTime: target, actualWakeTime: actual, isBlindTest: isBlindTest, isBlindDecoy: isBlindDecoy)
    }

    @Test("Hiç kör test gecesi yoksa tüm ortalamalar nil")
    func nilWhenNoBlindNights() {
        let nights = [(night: night(deviation: 10, isBlindTest: false, isBlindDecoy: false), reaction: Optional<ReactionTest>.none)]
        let result = BlindTestComparison.compare(nights: nights)
        #expect(result.realAverageAbsDeviationMinutes == nil)
        #expect(result.decoyAverageAbsDeviationMinutes == nil)
    }

    @Test("Gerçek ve sahte gecelerin sapma ortalamaları ayrı hesaplanır")
    func separatesRealAndDecoyDeviation() {
        let real1 = night(deviation: 10, isBlindTest: true, isBlindDecoy: false)
        let real2 = night(deviation: 20, isBlindTest: true, isBlindDecoy: false)
        let decoy1 = night(deviation: -30, isBlindTest: true, isBlindDecoy: true)

        let nights: [(night: Night, reaction: ReactionTest?)] = [
            (real1, nil), (real2, nil), (decoy1, nil)
        ]
        let result = BlindTestComparison.compare(nights: nights)
        #expect(result.realAverageAbsDeviationMinutes == 15)
        #expect(result.decoyAverageAbsDeviationMinutes == 30)
    }

    @Test("Tepki süresi ortalamaları gerçek/sahte gecelere göre ayrılır")
    func separatesReactionTimes() {
        let real = night(deviation: 0, isBlindTest: true, isBlindDecoy: false)
        let decoy = night(deviation: 0, isBlindTest: true, isBlindDecoy: true)
        let realReaction = ReactionTest(timestampsMs: [200, 300], testDate: .now) // avg 250
        let decoyReaction = ReactionTest(timestampsMs: [400], testDate: .now) // avg 400

        let nights: [(night: Night, reaction: ReactionTest?)] = [
            (real, realReaction), (decoy, decoyReaction)
        ]
        let result = BlindTestComparison.compare(nights: nights)
        #expect(result.realAverageReactionMs == 250)
        #expect(result.decoyAverageReactionMs == 400)
    }
}
