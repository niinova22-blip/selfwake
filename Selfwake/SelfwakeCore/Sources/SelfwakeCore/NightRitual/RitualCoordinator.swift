import Foundation

/// Gece Ritüeli'nin state machine'i — SwiftUI'dan bağımsız, saf mantık.
/// View katmanı yalnızca `state`'i okur ve `advance()`/`setFirstActionWord`
/// çağırır; hiçbir View ek içerik ya da geri gitme yolu eklemez (spec
/// Bölüm 4.1, "liste yok, açıklama paragrafı yok").
public struct RitualCoordinator {
    public private(set) var state: RitualState
    public let targetTime: Date
    public private(set) var firstActionWord: String?

    public init(targetTime: Date) {
        self.targetTime = targetTime
        self.state = .confirmTime
        self.firstActionWord = nil
    }

    /// `.fadeOut`'tan sonra hiçbir şey yapmaz — ritüel bitmiştir
    /// (spec Bölüm 4.3, ritüelin bitişi bir vaat değil sessiz bir son).
    public mutating func advance() {
        switch state {
        case .confirmTime: state = .step1SayTime
        case .step1SayTime: state = .step2Visualize
        case .step2Visualize: state = .step3FirstAction
        case .step3FirstAction: state = .fadeOut
        case .fadeOut: break
        }
    }

    /// Yalnızca `.step3FirstAction` state'indeyken anlamlı; başka bir
    /// state'te çağrılırsa sessizce yok sayılır (View zaten o state'te
    /// bu girişi göstermeyecek, ama coordinator kendi kendine tutarlı
    /// kalmalı).
    public mutating func setFirstActionWord(_ word: String) {
        guard state == .step3FirstAction else { return }
        firstActionWord = word
    }

    public var isComplete: Bool { state == .fadeOut }
}
