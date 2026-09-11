import Foundation

/// Ana uygulamanın bağlandığı arayüz — gerçek `UNUserNotificationCenter`
/// çağrıları yalnızca app hedefindeki `UNRitualReminderScheduler`'da
/// (spec Bölüm 2'deki AlarmScheduling ayrımıyla aynı gerekçe: framework
/// isimleri değişse bile geri kalan kod etkilenmez, ve bu protokol saf
/// Swift olduğu için burada, SelfwakeCore'da test edilebilir kalır).
public protocol NotificationScheduling {
    /// Kullanıcı bildirim iznini henüz vermediyse ister; sonucu döner.
    func requestAuthorization() async -> Bool

    /// Her gün aynı saat/dakikada tekrarlayan bir hatırlatıcı kurar.
    /// `targetTimeText` bildirim gövdesinde o geceki hedefi gösterir
    /// (örn. "07:00").
    func scheduleDailyReminder(hour: Int, minute: Int, targetTimeText: String) async

    /// Kullanıcı Ayarlar'dan hatırlatıcıyı kapatırsa çağrılır.
    func cancelReminder() async
}
