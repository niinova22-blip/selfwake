import Testing
import Foundation
@testable import SelfwakeCore

@Suite("ReactionTestSession")
struct ReactionTestSessionTests {
    @Test("Uyarıcı yokken dokunma yok sayılır")
    func tapWithoutStimulusIgnored() {
        var session = ReactionTestSession()
        session.start(at: .now)
        session.recordTap(at: .now.addingTimeInterval(1))
        #expect(session.recordedTimestampsMs.isEmpty)
    }

    @Test("Uyarıcıdan sonraki dokunma milisaniye cinsinden kaydedilir")
    func tapAfterStimulusRecordsElapsedMs() {
        var session = ReactionTestSession()
        let start = Date(timeIntervalSince1970: 0)
        session.start(at: start)
        session.stimulusAppeared(at: start)
        session.recordTap(at: start.addingTimeInterval(0.35))
        #expect(session.recordedTimestampsMs == [350])
    }

    @Test("Bir uyarıcı yalnızca bir dokunma üretir")
    func oneStimulusProducesOneTap() {
        var session = ReactionTestSession()
        let start = Date(timeIntervalSince1970: 0)
        session.start(at: start)
        session.stimulusAppeared(at: start)
        session.recordTap(at: start.addingTimeInterval(0.2))
        session.recordTap(at: start.addingTimeInterval(0.3)) // bekleyen uyarıcı yok
        #expect(session.recordedTimestampsMs.count == 1)
    }

    @Test("Süre dolmadan bitmiş sayılmaz")
    func notFinishedBeforeDuration() {
        var session = ReactionTestSession(duration: 30)
        let start = Date(timeIntervalSince1970: 0)
        session.start(at: start)
        #expect(!session.isFinished(at: start.addingTimeInterval(29)))
    }

    @Test("Süre dolunca bitmiş sayılır")
    func finishedAtDuration() {
        var session = ReactionTestSession(duration: 30)
        let start = Date(timeIntervalSince1970: 0)
        session.start(at: start)
        #expect(session.isFinished(at: start.addingTimeInterval(30)))
    }

    @Test("makeReactionTest kaydedilen değerleri taşır")
    func makeReactionTestCarriesRecordedValues() {
        var session = ReactionTestSession()
        let start = Date(timeIntervalSince1970: 0)
        session.start(at: start)
        session.stimulusAppeared(at: start)
        session.recordTap(at: start.addingTimeInterval(0.25))
        let test = session.makeReactionTest(testDate: start)
        #expect(test.timestampsMs == [250])
        #expect(test.averageMs == 250)
    }
}
