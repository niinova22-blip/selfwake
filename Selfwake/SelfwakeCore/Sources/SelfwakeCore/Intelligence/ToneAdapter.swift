import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Bölüm 8.1: kullanıcının son birkaç serbest notunu bağlam olarak verip
/// (few-shot, ayrı bir model eğitimi değil) `base`'in tonunu kullanıcının
/// kendi diline yaklaştırır. Not yoksa ya da model yoksa `base` değişmeden
/// döner — davranış farkı kullanıcıya hissettirilmez.
public struct ToneAdapter {
    let recentNotes: [String]

    public init(recentNotes: [String]) {
        self.recentNotes = recentNotes
    }

    public func adapt(_ base: String) async -> String {
        guard !recentNotes.isEmpty, case .available = IntelligenceAvailability.current() else {
            return RuleBasedFallbacks.toneNeutral(base)
        }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let session = LanguageModelSession(
                    instructions: "Verilen cümleyi anlamını değiştirmeden, örnek notların diline (resmi/samimi) yaklaştır."
                )
                let prompt = """
                Örnek notlar:
                \(recentNotes.joined(separator: "\n"))

                Uyarlanacak cümle: \(base)
                """
                let response = try await session.respond(to: prompt)
                return response.content
            } catch {
                return base
            }
        }
        #endif
        return base
    }
}
