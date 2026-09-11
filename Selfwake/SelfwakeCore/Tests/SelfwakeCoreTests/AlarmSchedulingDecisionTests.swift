import Testing
import Foundation
@testable import SelfwakeCore

@Suite("AlarmSchedulingDecision")
struct AlarmSchedulingDecisionTests {
    @Test("Hedef saatten önce açılırsa alarm iptal edilmeli")
    func cancelsWhenOpenedEarly() {
        let target = Date(timeIntervalSince1970: 1000)
        let openedAt = target.addingTimeInterval(-60)
        #expect(AlarmSchedulingDecision.shouldCancelBeforeRinging(targetTime: target, openedAppAt: openedAt))
    }

    @Test("Hedef saatten sonra açılırsa iptal edilmemeli (zaten çalmış ya da çalıyor)")
    func doesNotCancelWhenOpenedLate() {
        let target = Date(timeIntervalSince1970: 1000)
        let openedAt = target.addingTimeInterval(60)
        #expect(!AlarmSchedulingDecision.shouldCancelBeforeRinging(targetTime: target, openedAppAt: openedAt))
    }

    @Test("Çalma saati hedef + offset'tir")
    func fireDateAddsOffset() {
        let target = Date(timeIntervalSince1970: 0)
        let fireDate = AlarmSchedulingDecision.scheduledFireDate(targetTime: target, offsetMinutes: 9)
        #expect(fireDate == target.addingTimeInterval(9 * 60))
    }

    @Test("Offset sıfırsa çalma saati hedefle aynıdır")
    func fireDateEqualsTargetWhenOffsetZero() {
        let target = Date(timeIntervalSince1970: 0)
        let fireDate = AlarmSchedulingDecision.scheduledFireDate(targetTime: target, offsetMinutes: 0)
        #expect(fireDate == target)
    }
}
