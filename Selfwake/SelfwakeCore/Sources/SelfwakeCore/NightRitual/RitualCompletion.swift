import Foundation

/// Ritüel `.fadeOut`'a ulaştığında çağrılır — o geceye ait `Night`
/// taslağını kurar. `intentSentence` burada değil, Intelligence
/// katmanında üretilir (spec Bölüm 8); bu fonksiyon yalnızca ritüelin
/// kendi ürettiği veriyi (hedef saat, Adım 3 kelimesi) paketler.
public enum RitualCompletion {
    public static func makeNightDraft(
        date: Date,
        coordinator: RitualCoordinator,
        intentSentence: String? = nil
    ) -> Night? {
        guard coordinator.isComplete else { return nil }
        return Night(
            date: date,
            targetTime: coordinator.targetTime,
            intentSentence: intentSentence,
            firstActionWord: coordinator.firstActionWord
        )
    }
}
