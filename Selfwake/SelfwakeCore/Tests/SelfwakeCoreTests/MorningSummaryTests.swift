import Testing
import Foundation
@testable import SelfwakeCore

@Suite("MorningSummary")
struct MorningSummaryTests {
    @Test("Dün veri yoksa fark nil")
    func nilWhenNoYesterday() {
        let today = ReactionTest(timestampsMs: [300], testDate: .now)
        #expect(MorningSummary.reactionTimeDeltaMs(today: today, yesterday: nil) == nil)
    }

    @Test("Dün boş dizi ise fark nil")
    func nilWhenYesterdayEmpty() {
        let today = ReactionTest(timestampsMs: [300], testDate: .now)
        let yesterday = ReactionTest(timestampsMs: [], testDate: .now)
        #expect(MorningSummary.reactionTimeDeltaMs(today: today, yesterday: yesterday) == nil)
    }

    @Test("Bugün daha hızlıysa fark negatiftir")
    func negativeWhenFaster() {
        let today = ReactionTest(timestampsMs: [250], testDate: .now)
        let yesterday = ReactionTest(timestampsMs: [300], testDate: .now)
        #expect(MorningSummary.reactionTimeDeltaMs(today: today, yesterday: yesterday) == -50)
    }

    @Test("Bugün daha yavaşsa fark pozitiftir")
    func positiveWhenSlower() {
        let today = ReactionTest(timestampsMs: [350], testDate: .now)
        let yesterday = ReactionTest(timestampsMs: [300], testDate: .now)
        #expect(MorningSummary.reactionTimeDeltaMs(today: today, yesterday: yesterday) == 50)
    }
}
