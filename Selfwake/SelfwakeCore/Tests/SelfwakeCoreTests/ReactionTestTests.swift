import Testing
import Foundation
@testable import SelfwakeCore

@Suite("ReactionTest ortalama hesabı")
struct ReactionTestTests {
    @Test("Boş dizide ortalama sıfır")
    func averageZeroWhenEmpty() {
        let test = ReactionTest(timestampsMs: [], testDate: .now)
        #expect(test.averageMs == 0)
    }

    @Test("Ortalama doğru hesaplanır")
    func averageComputedCorrectly() {
        let test = ReactionTest(timestampsMs: [200, 300, 400], testDate: .now)
        #expect(test.averageMs == 300)
    }

    @Test("Night ilişkisi atanabilir")
    func nightRelationshipAssignable() {
        let night = Night(date: .now, targetTime: .now)
        let test = ReactionTest(night: night, timestampsMs: [250], testDate: .now)
        #expect(test.night === night)
    }
}
