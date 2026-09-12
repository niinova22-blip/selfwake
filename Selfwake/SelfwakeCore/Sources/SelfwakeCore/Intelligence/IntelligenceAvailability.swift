import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Spec Bölüm 2 madde 3: `SystemLanguageModel.default.availability`'nin
/// tam dönüş tiplerini Apple'ın resmi dokümantasyonu olmadan birebir
/// yazamıyoruz — bu yüzden `#if canImport` ile korunuyor ve her hata
/// durumunda sessizce `.unavailable`'a düşüyor. Codemagic'teki ilk
/// derleme gerçek API yüzeyini doğrulayacak.
public enum IntelligenceAvailability {
    case available
    case unavailable(reason: String)

    public static func current() -> IntelligenceAvailability {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return .available
            case .unavailable(let reason):
                return .unavailable(reason: String(describing: reason))
            @unknown default:
                return .unavailable(reason: "bilinmeyen durum")
            }
        }
        #endif
        return .unavailable(reason: "Foundation Models bu platformda yok")
    }
}
