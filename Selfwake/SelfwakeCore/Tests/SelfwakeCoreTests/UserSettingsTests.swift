import Testing
import Foundation
@testable import SelfwakeCore

@Suite("UserSettings varsayılan değerler")
struct UserSettingsTests {
    @Test("Yeni ayar nesnesi güvenli varsayılanlarla başlar")
    func defaultsAreSafe() {
        let settings = UserSettings(targetTimeDefault: .now)
        #expect(settings.currentStreak == 0)
        #expect(settings.bestStreak == 0)
        #expect(settings.alarmOffsetMinutes == 0)
        #expect(settings.alarmVolumeLevel == 1.0)
        #expect(settings.blindTestEnabled == false)
        #expect(settings.healthKitEnabled == false)
        #expect(settings.themeID == "nightBlue")
        #expect(settings.reduceMotionOverride == nil)
        #expect(settings.onboardingCompleted == false)
        #expect(settings.breathSoundEnabled == false)
        #expect(settings.calendarEnabled == false)
        #expect(settings.watchCompanionEnabled == false)
        #expect(settings.liveActivityEnabled == true)
    }
}
