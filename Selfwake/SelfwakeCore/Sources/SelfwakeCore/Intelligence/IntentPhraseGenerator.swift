import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

public struct IntentPhraseGenerator: SentenceGenerating {
    let targetTime: Date
    let firstEventTitle: String?

    public init(targetTime: Date, firstEventTitle: String?) {
        self.targetTime = targetTime
        self.firstEventTitle = firstEventTitle
    }

    public func generate() async -> String {
        let fallback = RuleBasedFallbacks.intentSentence(targetTime: targetTime, firstEventTitle: firstEventTitle)
        guard case .available = IntelligenceAvailability.current() else { return fallback }
        #if canImport(FoundationModels)
        do {
            let session = LanguageModelSession(
                instructions: "Tek cümlelik, sakin bir niyet cümlesi yaz. Tıbbi tavsiye verme, abartma."
            )
            let time = targetTime.formatted(date: .omitted, time: .shortened)
            let prompt = "Hedef saat: \(time). Ertesi günün ilk işi: \(firstEventTitle ?? "belirtilmedi")."
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
