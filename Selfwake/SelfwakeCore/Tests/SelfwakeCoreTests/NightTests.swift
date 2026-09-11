import Testing
import Foundation
@testable import SelfwakeCore

@Suite("Night sapma ve başarı hesapları")
struct NightTests {
    @Test("Sapma dakika cinsinden, geç uyanma pozitif")
    func deviationPositiveWhenLate() {
        let target = Date(timeIntervalSince1970: 0)
        let actual = target.addingTimeInterval(20 * 60)
        let night = Night(date: target, targetTime: target, actualWakeTime: actual)
        #expect(night.deviationMinutes == 20)
    }

    @Test("Erken uyanma negatif sapma verir")
    func deviationNegativeWhenEarly() {
        let target = Date(timeIntervalSince1970: 0)
        let actual = target.addingTimeInterval(-10 * 60)
        let night = Night(date: target, targetTime: target, actualWakeTime: actual)
        #expect(night.deviationMinutes == -10)
    }

    @Test("Tam 30 dakika sapma hâlâ başarı sayılır (eşik dahil)")
    func successAtExactThreshold() {
        let target = Date(timeIntervalSince1970: 0)
        let actual = target.addingTimeInterval(30 * 60)
        let night = Night(date: target, targetTime: target, actualWakeTime: actual)
        #expect(night.isSuccess == true)
    }

    @Test("30 dakikadan fazla sapma başarısızlık sayılır")
    func failureBeyondThreshold() {
        let target = Date(timeIntervalSince1970: 0)
        let actual = target.addingTimeInterval(31 * 60)
        let night = Night(date: target, targetTime: target, actualWakeTime: actual)
        #expect(night.isSuccess == false)
    }

    @Test("Henüz uyanılmadıysa sapma ve başarı nil")
    func nilBeforeWaking() {
        let target = Date(timeIntervalSince1970: 0)
        let night = Night(date: target, targetTime: target)
        #expect(night.deviationMinutes == nil)
        #expect(night.isSuccess == nil)
    }

    @Test("firstActionWord ve freeNote birbirinden bağımsız saklanır")
    func firstActionWordIndependentFromFreeNote() {
        let target = Date(timeIntervalSince1970: 0)
        let night = Night(
            date: target,
            targetTime: target,
            firstActionWord: "su",
            freeNote: "dün gece huzursuzdum"
        )
        #expect(night.firstActionWord == "su")
        #expect(night.freeNote == "dün gece huzursuzdum")
    }
}
