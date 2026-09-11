import Testing
@testable import SelfwakeCore

@Suite("PlusGate")
struct PlusGateTests {
    @Test("Ücretsiz kademede hiçbir Plus özelliği açık değil")
    func freeTierLocksEverything() {
        for feature in PlusFeature.allCases {
            #expect(!PlusGate.isUnlocked(feature, tier: .free))
        }
    }

    @Test("Plus kademede tüm özellikler açık")
    func plusTierUnlocksEverything() {
        for feature in PlusFeature.allCases {
            #expect(PlusGate.isUnlocked(feature, tier: .plus))
        }
    }
}
