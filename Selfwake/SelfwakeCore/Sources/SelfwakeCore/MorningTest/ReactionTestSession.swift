import Foundation

/// 30 saniyelik psikomotor uyanıklık testi (PVT-lite, spec Bölüm 5,
/// "Sabah"): ekran rengi değişince dokun, tepki süresi kaydedilir.
/// SwiftUI'dan bağımsız — `ReactionTestView` yalnızca ekran rengini
/// değiştirip bu tipin `stimulusAppeared`/`recordTap` metotlarını çağırır.
public struct ReactionTestSession {
    public let duration: TimeInterval
    public private(set) var startedAt: Date?
    public private(set) var stimulusShownAt: Date?
    public private(set) var recordedTimestampsMs: [Double] = []

    public init(duration: TimeInterval = 30) {
        self.duration = duration
    }

    public mutating func start(at now: Date) {
        startedAt = now
    }

    /// Ekran rengi değiştiği an çağrılır.
    public mutating func stimulusAppeared(at now: Date) {
        stimulusShownAt = now
    }

    /// Kullanıcı dokunduğunda çağrılır. Bekleyen bir uyarıcı yoksa
    /// (erken/rastgele dokunma) yok sayılır — testi bozmaz.
    public mutating func recordTap(at now: Date) {
        guard let shown = stimulusShownAt else { return }
        let elapsedMs = now.timeIntervalSince(shown) * 1000
        recordedTimestampsMs.append(elapsedMs)
        stimulusShownAt = nil
    }

    public func isFinished(at now: Date) -> Bool {
        guard let started = startedAt else { return false }
        return now.timeIntervalSince(started) >= duration
    }

    public func makeReactionTest(testDate: Date) -> ReactionTest {
        ReactionTest(timestampsMs: recordedTimestampsMs, testDate: testDate)
    }
}
