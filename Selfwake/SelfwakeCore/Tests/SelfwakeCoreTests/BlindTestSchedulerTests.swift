import Testing
@testable import SelfwakeCore

@Suite("BlindTestScheduler ataması")
struct BlindTestSchedulerTests {
    @Test("Kör test kapalıysa zar ne olursa olsun dahil edilmez")
    func disabledNeverIncludes() {
        let result = BlindTestScheduler.assign(blindTestEnabled: false, inclusionRoll: 0, decoyRoll: 0)
        #expect(!result.isBlindTest)
        #expect(!result.isBlindDecoy)
    }

    @Test("Dahil olma eşiğinin üstündeki zar kapsama girmez")
    func aboveInclusionThresholdExcluded() {
        let result = BlindTestScheduler.assign(blindTestEnabled: true, inclusionRoll: 0.9, decoyRoll: 0)
        #expect(!result.isBlindTest)
        #expect(!result.isBlindDecoy)
    }

    @Test("Dahil + düşük sahte zarı -> sahte gece")
    func includedAndLowDecoyRollIsDecoy() {
        let result = BlindTestScheduler.assign(blindTestEnabled: true, inclusionRoll: 0.1, decoyRoll: 0.1)
        #expect(result.isBlindTest)
        #expect(result.isBlindDecoy)
    }

    @Test("Dahil + yüksek sahte zarı -> gerçek ama işaretli gece")
    func includedAndHighDecoyRollIsReal() {
        let result = BlindTestScheduler.assign(blindTestEnabled: true, inclusionRoll: 0.1, decoyRoll: 0.9)
        #expect(result.isBlindTest)
        #expect(!result.isBlindDecoy)
    }
}
