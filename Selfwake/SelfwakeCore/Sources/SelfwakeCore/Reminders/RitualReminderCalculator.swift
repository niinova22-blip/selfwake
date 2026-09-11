import Foundation

/// Gece Ritüeli hatırlatıcısı için saf hesap. Bildirimi gerçekten kuran
/// kod (UNUserNotificationCenter) app hedefinde `NotificationScheduling`
/// arkasında yaşıyor — burada yalnızca "ne zaman" sorusu cevaplanıyor.
public enum RitualReminderCalculator {
    /// Hedef saatten hatırlatıcıya kadar geriye sayılan tipik uyku süresi.
    /// Kullanıcı Ayarlar'dan `UserSettings.reminderTime`'ı elle değiştirebilir;
    /// bu yalnızca onboarding'deki ilk öneri.
    public static let defaultLeadHours = 8

    public static func defaultReminderTime(forTarget targetTime: Date, calendar: Calendar = .current) -> Date {
        targetTime.addingTimeInterval(-Double(defaultLeadHours) * 3600)
    }

    /// `reminderTime`'ın yalnızca saat/dakika bileşenini döner —
    /// `UNCalendarNotificationTrigger(dateMatching:repeats:true)` için.
    public static func hourMinuteComponents(from reminderTime: Date, calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents([.hour, .minute], from: reminderTime)
    }
}
