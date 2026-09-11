import Testing
import Foundation
@testable import SelfwakeCore

@Suite("RuleBasedFallbacks")
struct RuleBasedFallbacksTests {
    @Test("Adaptif öneri 5'ten az gecede nil")
    func adaptiveSuggestionRequiresFiveNights() {
        #expect(RuleBasedFallbacks.adaptiveTargetTimeSuggestion(recentDeviationsMinutes: [20, 20, 20]) == nil)
    }

    @Test("Ortalama sapma düşükse öneri yok")
    func noSuggestionWhenAverageLow() {
        let deviations = [5.0, 5, 5, 5, 5]
        #expect(RuleBasedFallbacks.adaptiveTargetTimeSuggestion(recentDeviationsMinutes: deviations) == nil)
    }

    @Test("Ortalama sapma yüksekse öneri üretilir")
    func suggestsWhenAverageHigh() {
        let deviations = [20.0, 25, 15, 30, 20]
        #expect(RuleBasedFallbacks.adaptiveTargetTimeSuggestion(recentDeviationsMinutes: deviations) != nil)
    }

    @Test("Yatış saati 30 dakikadan az geçse uyarı yok")
    func noWarningUnderThreshold() {
        #expect(RuleBasedFallbacks.eveningRiskWarning(bedTimeDeltaMinutes: 20) == nil)
    }

    @Test("Yatış saati 30 dakikadan çok geçse uyarı üretilir")
    func warnsOverThreshold() {
        #expect(RuleBasedFallbacks.eveningRiskWarning(bedTimeDeltaMinutes: 45) != nil)
    }

    @Test("Sapma yoksa sabah yorumu ölçüm yok der")
    func morningCommentNilDeviation() {
        #expect(RuleBasedFallbacks.morningComment(deviationMinutes: nil) == "Bu sabah henüz bir ölçüm yok.")
    }
}
