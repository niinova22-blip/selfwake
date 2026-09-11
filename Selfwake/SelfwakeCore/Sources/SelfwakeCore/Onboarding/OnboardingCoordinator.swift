import Foundation

/// Onboarding sırası — spec Bölüm 5 madde 1. Ritüel'in aksine burada geri
/// gidiş var: dürüstlük uyarısını ya da bilimsel temeli tekrar okumak
/// isteyen biri engellenmemeli.
public enum OnboardingStep: Int, CaseIterable {
    /// Vaat: "Sabahları yorgun uyanmayın. Alarm kurmayı bırakın — beyninizde
    /// çalan sese güvenin."
    case welcome
    /// Dört adımlık akışın düz Türkçe özeti (gece → güvenlik ağı → sabah → geri çekilme).
    case howItWorks
    /// Kaynakçalı bilimsel temel (Born ve ark. 1999; Ikeda & Hayashi 2014).
    case science
    /// "Herkes yapamaz" uyarısı, düzensiz hedefin uykuyu bozması.
    case honesty
    /// AlarmKit (zorunlu), bildirim (hatırlatıcı için), HealthKit (opsiyonel).
    case permissions
    /// Ritüel hatırlatıcısının saati — `RitualReminderCalculator` öneriyor.
    case reminderSetup
    /// İlk hedef uyanma saati.
    case targetTimeSetup

    public var isFirst: Bool { self == .welcome }
    public var isLast: Bool { self == .targetTimeSetup }
}

public struct OnboardingCoordinator {
    public private(set) var step: OnboardingStep
    public private(set) var isComplete: Bool

    public init() {
        self.step = .welcome
        self.isComplete = false
    }

    public mutating func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else {
            isComplete = true
            return
        }
        step = next
    }

    public mutating func goBack() {
        guard let previous = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }
}
