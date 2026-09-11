import Foundation

/// Gece Ritüeli'nin dört adımı (spec Bölüm 4.1) — tek yönlü, geri yok.
/// Her state'in View katmanında karşılığı tam olarak bir ekran, tek bir
/// birincil içerik: bu kısıt burada değil `RitualCoordinator.advance()`'in
/// doğrusal ilerlemesiyle zorlanıyor.
public enum RitualState: Equatable {
    case confirmTime
    case step1SayTime
    case step2Visualize
    case step3FirstAction
    case fadeOut
}
