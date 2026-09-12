import Foundation
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

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

/// iOS 26 altındaki cihazlarda (AlarmKit yok) yerel bildirim izni bu tipin
/// yerine geçer — `AlarmSchedulerFactory` ile aynı sürüm eşiğini paylaşır.
public enum AlarmPermissionManager {
    public static func currentState() -> AlarmPermissionState {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            switch AlarmManager.shared.authorizationState {
            case .notDetermined: return .notDetermined
            case .authorized: return .authorized
            case .denied: return .denied
            @unknown default: return .denied
            }
        }
        #endif
        return .notDetermined
    }

    /// Kullanıcı reddederse `AppRouter` bildirim tabanlı yedek moda düşer
    /// (spec Bölüm 2 madde 2) — bu fonksiyon yalnızca durumu döner, yedek
    /// moda geçiş kararı UI katmanında.
    public static func requestAuthorization() async -> AlarmPermissionState {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
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
        #endif
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .criticalAlert])
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }
}
