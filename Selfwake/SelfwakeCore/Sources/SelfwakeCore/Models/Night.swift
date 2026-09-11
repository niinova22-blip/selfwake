import Foundation
import SwiftData

@Model
public final class Night: Identifiable {
    public var id: UUID
    public var date: Date
    public var targetTime: Date
    public var actualWakeTime: Date?
    public var bedTime: Date?
    public var alarmDidRing: Bool
    public var isBlindTest: Bool
    public var isBlindDecoy: Bool
    public var intentSentence: String?
    /// Gece Ritüeli Adım 3: "uyanınca ilk yapacağın şeyi tek kelimeyle yaz".
    /// `freeNote`'tan ayrı — o daha sonra (sabah ya da gündüz) serbestçe
    /// eklenen bir not, bu ise ritüelin kendi üçüncü adımının girdisi.
    public var firstActionWord: String?
    public var freeNote: String?

    public init(
        id: UUID = UUID(),
        date: Date,
        targetTime: Date,
        actualWakeTime: Date? = nil,
        bedTime: Date? = nil,
        alarmDidRing: Bool = false,
        isBlindTest: Bool = false,
        isBlindDecoy: Bool = false,
        intentSentence: String? = nil,
        firstActionWord: String? = nil,
        freeNote: String? = nil
    ) {
        self.id = id
        self.date = date
        self.targetTime = targetTime
        self.actualWakeTime = actualWakeTime
        self.bedTime = bedTime
        self.alarmDidRing = alarmDidRing
        self.isBlindTest = isBlindTest
        self.isBlindDecoy = isBlindDecoy
        self.intentSentence = intentSentence
        self.firstActionWord = firstActionWord
        self.freeNote = freeNote
    }

    /// `actualWakeTime - targetTime`, dakika. Pozitif = geç, negatif = erken.
    public var deviationMinutes: Double? {
        guard let actual = actualWakeTime else { return nil }
        return actual.timeIntervalSince(targetTime) / 60
    }

    /// ±30 dakika literatür eşiği (spec Bölüm 5, "İlerleme").
    public var isSuccess: Bool? {
        guard let d = deviationMinutes else { return nil }
        return abs(d) <= 30
    }
}
