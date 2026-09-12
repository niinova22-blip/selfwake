import Foundation
import UserNotifications
#if canImport(AlarmKit)
import AlarmKit
#endif

/// Uygulamanın geri kalanının bağlandığı arayüz — gerçek AlarmKit çağrıları
/// yalnızca `AlarmKitScheduler`'da. Bu ayrım sayesinde AlarmKit'in kesin isim
/// ve imzaları (spec Bölüm 2 madde 1-2) Codemagic'te derlenirken düzeltilse
/// bile geri kalan kod (`RitualCoordinator`, `AppRouter`) etkilenmez.
public protocol AlarmScheduling {
    func schedule(id: UUID, fireDate: Date, volumeLevel: Double) async throws
    func cancel(id: UUID) async throws
}

/// iOS sürümüne göre doğru uygulamayı seçer: AlarmKit (iOS 26+, sessiz modu
/// delebilir) ya da yerel bildirim (daha eski cihazlar — iPhone 11/iOS 18
/// gibi AlarmKit'in çalışamadığı donanımlar için zorunlu yedek).
public enum AlarmSchedulerFactory {
    public static func make() -> AlarmScheduling {
        #if canImport(AlarmKit)
        if #available(iOS 26.0, *) {
            return AlarmKitScheduler()
        }
        #endif
        return NotificationAlarmScheduler()
    }
}

#if canImport(AlarmKit)
/// AlarmKit boş metadata gerektiriyor (spec araştırmasında görülen örnek:
/// `EmptyMetadata`). `nonisolated` işareti Apple'ın kendi örneklerinde de var.
@available(iOS 26.0, *)
public struct SelfwakeAlarmMetadata: AlarmMetadata {
    public init() {}
}

@available(iOS 26.0, *)
public struct AlarmKitScheduler: AlarmScheduling {
    public init() {}

    public func schedule(id: UUID, fireDate: Date, volumeLevel: Double) async throws {
        let presentation = AlarmPresentation(
            alert: .init(
                title: "Selfwake",
                stopButton: .init(text: "Kapat", textColor: .white, systemImageName: "xmark")
            )
        )
        let attributes = AlarmAttributes<SelfwakeAlarmMetadata>(
            presentation: presentation,
            tintColor: .accentColor
        )
        let configuration = AlarmManager.AlarmConfiguration<SelfwakeAlarmMetadata>.alarm(
            schedule: .fixed(fireDate),
            attributes: attributes
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        // volumeLevel: AlarmKit'in ses seviyesi API'si Apple dokümantasyonuyla
        // teyit edilene kadar burada uygulanmıyor — spec Bölüm 2'ye açık risk
        // olarak not düşüldü, sistemin kendi ses ayarına düşülüyor.
    }

    public func cancel(id: UUID) async throws {
        try AlarmManager.shared.cancel(id: id)
    }
}
#endif

/// AlarmKit'in olmadığı (iOS < 26) cihazlar için yedek: sessiz modu delemez,
/// ama zamanlı, sesli bir yerel bildirimle aynı işlevi büyük ölçüde görür.
/// Kullanıcı iPhone'unu iOS 26'ya yükseltemediğinde (ör. iPhone 11) tek
/// seçenek budur.
public struct NotificationAlarmScheduler: AlarmScheduling {
    public init() {}

    public func schedule(id: UUID, fireDate: Date, volumeLevel: Double) async throws {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Selfwake"
        content.body = "Güvenlik ağı çalıyor — uyanma vakti."
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive

        let interval = max(fireDate.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        try await center.add(request)
    }

    public func cancel(id: UUID) async throws {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
