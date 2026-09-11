import Foundation
import SwiftData

@Model
public final class UserSettings {
    public var targetTimeDefault: Date
    public var currentStreak: Int
    public var bestStreak: Int
    /// Ağın hedef saatten kaç dakika sonra çalacağı — spec Bölüm 4.4, StreakCalculator besler.
    public var alarmOffsetMinutes: Int
    /// 0.0-1.0, asla 0 olmaz (spec Bölüm 4.2 "tamamen kapatılamaz").
    public var alarmVolumeLevel: Double
    public var blindTestEnabled: Bool
    public var healthKitEnabled: Bool
    public var themeID: String
    /// nil = sistem "Hareketi Azalt" ayarını izle.
    public var reduceMotionOverride: Bool?
    public var onboardingCompleted: Bool
    public var breathSoundEnabled: Bool
    public var calendarEnabled: Bool
    public var watchCompanionEnabled: Bool
    public var liveActivityEnabled: Bool
    /// Ritüel hatırlatıcı bildirimi açık mı (Bölüm 4.8).
    public var reminderEnabled: Bool
    /// Hatırlatıcının çalacağı saat/dakika (yıl/ay/gün önemsiz, `UNCalendarNotificationTrigger`
    /// yalnızca `.hour`/`.minute` bileşenlerini okuyacak). Onboarding'de
    /// `RitualReminderCalculator.defaultReminderTime` ile önerilir, kullanıcı değiştirebilir.
    public var reminderTime: Date

    public init(targetTimeDefault: Date) {
        self.targetTimeDefault = targetTimeDefault
        self.currentStreak = 0
        self.bestStreak = 0
        self.alarmOffsetMinutes = 0
        self.alarmVolumeLevel = 1.0
        self.blindTestEnabled = false
        self.healthKitEnabled = false
        self.themeID = "nightBlue"
        self.reduceMotionOverride = nil
        self.onboardingCompleted = false
        self.breathSoundEnabled = false
        self.calendarEnabled = false
        self.watchCompanionEnabled = false
        self.liveActivityEnabled = true
        self.reminderEnabled = true
        self.reminderTime = RitualReminderCalculator.defaultReminderTime(forTarget: targetTimeDefault)
    }
}
