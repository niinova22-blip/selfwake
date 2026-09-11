import Testing
import Foundation
@testable import SelfwakeCore

@Suite("RitualCoordinator ilerleme")
struct RitualCoordinatorTests {
    @Test("Başlangıç durumu confirmTime'dır")
    func startsAtConfirmTime() {
        let coordinator = RitualCoordinator(targetTime: .now)
        #expect(coordinator.state == .confirmTime)
        #expect(!coordinator.isComplete)
    }

    @Test("Dört advance() çağrısı fadeOut'a ulaştırır")
    func fourAdvancesReachFadeOut() {
        var coordinator = RitualCoordinator(targetTime: .now)
        coordinator.advance() // step1SayTime
        coordinator.advance() // step2Visualize
        coordinator.advance() // step3FirstAction
        coordinator.advance() // fadeOut
        #expect(coordinator.state == .fadeOut)
        #expect(coordinator.isComplete)
    }

    @Test("fadeOut'tan sonra advance() hiçbir şey değiştirmez")
    func advanceIsNoOpAfterFadeOut() {
        var coordinator = RitualCoordinator(targetTime: .now)
        for _ in 0..<10 { coordinator.advance() }
        #expect(coordinator.state == .fadeOut)
    }

    @Test("Sıra doğrusal: adımlar atlanamaz")
    func stepsAreSequential() {
        var coordinator = RitualCoordinator(targetTime: .now)
        coordinator.advance()
        #expect(coordinator.state == .step1SayTime)
        coordinator.advance()
        #expect(coordinator.state == .step2Visualize)
        coordinator.advance()
        #expect(coordinator.state == .step3FirstAction)
    }

    @Test("step3FirstAction dışında setFirstActionWord yok sayılır")
    func firstActionWordIgnoredOutsideStep3() {
        var coordinator = RitualCoordinator(targetTime: .now)
        coordinator.setFirstActionWord("su")
        #expect(coordinator.firstActionWord == nil)
    }

    @Test("step3FirstAction'da setFirstActionWord kaydedilir")
    func firstActionWordRecordedDuringStep3() {
        var coordinator = RitualCoordinator(targetTime: .now)
        coordinator.advance()
        coordinator.advance()
        coordinator.advance()
        #expect(coordinator.state == .step3FirstAction)
        coordinator.setFirstActionWord("su")
        #expect(coordinator.firstActionWord == "su")
    }
}
