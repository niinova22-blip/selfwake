import Testing
import Foundation
@testable import SelfwakeCore

@Suite("RitualCompletion Night taslağı")
struct RitualCompletionTests {
    @Test("Ritüel tamamlanmadıysa nil döner")
    func nilWhenIncomplete() {
        var coordinator = RitualCoordinator(targetTime: .now)
        coordinator.advance() // yalnızca step1
        let night = RitualCompletion.makeNightDraft(date: .now, coordinator: coordinator)
        #expect(night == nil)
    }

    @Test("Tamamlanan ritüel hedef saati ve kelimeyi taşıyan bir Night üretir")
    func completedRitualProducesNight() {
        let target = Date(timeIntervalSince1970: 1000)
        var coordinator = RitualCoordinator(targetTime: target)
        coordinator.advance()
        coordinator.advance()
        coordinator.advance()
        coordinator.setFirstActionWord("su")
        coordinator.advance() // fadeOut

        let night = RitualCompletion.makeNightDraft(
            date: .now,
            coordinator: coordinator,
            intentSentence: "Bugün toplantı var."
        )

        #expect(night?.targetTime == target)
        #expect(night?.firstActionWord == "su")
        #expect(night?.intentSentence == "Bugün toplantı var.")
    }
}
