import Testing
import Foundation
@testable import SelfwakeCore

@Suite("RitualReminderCalculator")
struct RitualReminderCalculatorTests {
    @Test("Varsayılan hatırlatıcı hedeften 8 saat önce")
    func defaultsToEightHoursBefore() {
        let target = Date(timeIntervalSince1970: 100_000)
        let reminder = RitualReminderCalculator.defaultReminderTime(forTarget: target)
        #expect(reminder == target.addingTimeInterval(-8 * 3600))
    }

    @Test("Saat/dakika bileşenleri doğru çıkarılır")
    func extractsHourMinute() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let reminder = calendar.date(from: DateComponents(year: 2026, month: 9, day: 11, hour: 22, minute: 30))!
        let components = RitualReminderCalculator.hourMinuteComponents(from: reminder, calendar: calendar)
        #expect(components.hour == 22)
        #expect(components.minute == 30)
    }
}
