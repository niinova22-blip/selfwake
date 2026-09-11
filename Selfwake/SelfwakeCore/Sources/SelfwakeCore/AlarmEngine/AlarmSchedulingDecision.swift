import Foundation

/// AlarmKit'e hiç bağımlı değil — "ne zaman kur, ne zaman iptal et" kararı
/// saf mantık olarak burada, framework çağrıları `AlarmScheduler`'da.
/// Bölüm 4.2: kullanıcı hedef saatten önce uygulamayı açarsa ağ hiç çalmaz.
public enum AlarmSchedulingDecision {
    /// `now`, `targetTime`'dan önceyse ve kullanıcı henüz uyanmamışsa
    /// (yani uygulamayı hedef saatten önce açtıysa) alarm iptal edilmeli.
    public static func shouldCancelBeforeRinging(targetTime: Date, openedAppAt now: Date) -> Bool {
        now < targetTime
    }

    /// Bir sonraki gece için kurulacak alarmın gerçek çalma saati:
    /// hedef saat + kademenin offset'i (spec Bölüm 4.4).
    public static func scheduledFireDate(targetTime: Date, offsetMinutes: Int) -> Date {
        targetTime.addingTimeInterval(TimeInterval(offsetMinutes * 60))
    }
}
