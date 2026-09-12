import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

public struct WeeklyPatternSummarizer: SentenceGenerating {
    let successRate: Double?

    public init(successRate: Double?) {
        self.successRate = successRate
    }

    public func generate() async -> String {
        let fallback = RuleBasedFallbacks.weeklyPatternSummary(successRate: successRate)
        guard case .available = IntelligenceAvailability.current() else { return fallback }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    instructions: "Haftalık başarı oranını düz Türkçe, tek cümlelik bir gözleme çevir. İstatistiksel test iddiası yapma."
                )
                let rateText = successRate.map { "%\(Int($0 * 100))" } ?? "veri yok"
                let response = try await session.respond(to: "Bu haftaki başarı oranı: \(rateText)")
                return response.content
            } catch {
                return fallback
            }
        }
        #endif
        return fallback
    }
}
