import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

public struct JournalThemeExtractor: SentenceGenerating {
    let notes: [String]

    public init(notes: [String]) {
        self.notes = notes
    }

    public func generate() async -> String {
        let fallback = RuleBasedFallbacks.journalThemes(notes: notes)
        guard !notes.isEmpty, case .available = IntelligenceAvailability.current() else { return fallback }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    instructions: "Serbest notlardaki tekrar eden temayı tek cümleyle özetle. Tema yoksa bunu söyle."
                )
                let response = try await session.respond(to: notes.joined(separator: "\n"))
                return response.content
            } catch {
                return fallback
            }
        }
        #endif
        return fallback
    }
}
