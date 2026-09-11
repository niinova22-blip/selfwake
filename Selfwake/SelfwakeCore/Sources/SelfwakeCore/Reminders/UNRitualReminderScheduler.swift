import Foundation
import UserNotifications

/// `NotificationScheduling`'in gerçek `UserNotifications` uygulaması.
/// AlarmKit'teki gibi cihaz/simülatör olmadan test edilemiyor —
/// doğrulama Codemagic/TestFlight'ta yapılacak (spec Bölüm 2).
public struct UNRitualReminderScheduler: NotificationScheduling {
    /// Ayarlar'da hatırlatıcı kapatılıp açıldığında aynı kimlik yeniden kullanılır.
    public static let identifier = "com.selfwake.app.ritualReminder"

    public init() {}

    public func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    public func scheduleDailyReminder(hour: Int, minute: Int, targetTimeText: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier])

        let content = UNMutableNotificationContent()
        content.title = "Gece ritüelinin vakti geldi"
        content.body = "Bu gece \(targetTimeText) hedefliyorsun. İki dakikanı ayır."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: Self.identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    public func cancelReminder() async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.identifier])
    }
}
