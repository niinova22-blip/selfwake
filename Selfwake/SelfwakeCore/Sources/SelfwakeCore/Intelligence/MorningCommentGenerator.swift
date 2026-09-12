import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

public struct MorningCommentGenerator: SentenceGenerating {
    let deviationMinutes: Double?
    let reactionDeltaMs: Double?
    let bedTimeText: String?

    public init(deviationMinutes: Double?, reactionDeltaMs: Double?, bedTimeText: String?) {
        self.deviationMinutes = deviationMinutes
        self.reactionDeltaMs = reactionDeltaMs
        self.bedTimeText = bedTimeText
    }

    public func generate() async -> String {
        let fallback = RuleBasedFallbacks.morningComment(deviationMinutes: deviationMinutes)
        guard case .available = IntelligenceAvailability.current() else { return fallback }
        #if canImport(FoundationModels)
        do {
            let session = LanguageModelSession(
                instructions: "Gece sapması, tepki süresi ve yatış saatini birlikte okuyup tek cümlelik bir gözlem yaz."
            )
            let deviationText: String = deviationMinutes.map { String($0) } ?? "yok"
            let reactionDeltaText: String = reactionDeltaMs.map { String($0) } ?? "yok"
            let bedTimeSummary: String = bedTimeText ?? "bilinmiyor"
            let prompt = """
            Sapma (dakika): \(deviationText)
            Tepki süresi farkı (ms): \(reactionDeltaText)
            Yatış saati: \(bedTimeSummary)
            """
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return fallback
        }
        #else
        return fallback
        #endif
    }
}
