import Foundation
import AlarmKit

/// `AlarmManager.AuthorizationState`'in kendi soyutlamamız — çağıran kod
/// (Onboarding, Ayarlar) AlarmKit'in kendi tipine değil buna bağımlı olsun
/// diye. AlarmKit'in tam durum adları Apple dokümantasyonuyla teyit
/// edilene kadar bu üç durum WWDC25/topluluk örnekleriyle doğrulandı
/// (bkz. spec Bölüm 2 madde 2).
public enum AlarmPermissionState {
    case notDetermined
    case authorized
    case denied
}

public enum AlarmPermissionManager {
    public static func currentState() -> AlarmPermissionState {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        @unknown default: return .denied
        }
    }

    /// Kullanıcı reddederse `AppRouter` bildirim tabanlı yedek moda düşer
    /// (spec Bölüm 2 madde 2) — bu fonksiyon yalnızca durumu döner, yedek
    /// moda geçiş kararı UI katmanında.
    public static func requestAuthorization() async -> AlarmPermissionState {
        do {
            let result = try await AlarmManager.shared.requestAuthorization()
            switch result {
            case .authorized: return .authorized
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            @unknown default: return .denied
            }
        } catch {
            return .denied
        }
    }
}
