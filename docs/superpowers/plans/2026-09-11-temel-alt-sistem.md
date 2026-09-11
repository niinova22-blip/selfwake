# Temel Alt Sistem (Persistence + Models + StreakCalculator) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Selfwake'in geri kalan her alt sisteminin üzerine kurulacağı bağımsız, UI'sız `SelfwakeCore` Swift paketini kurmak: SwiftData modelleri (`Night`, `ReactionTest`, `UserSettings`), App Group destekli kalıcılık katmanı ve kademeli alarm geri çekilme mantığı (`StreakCalculator`).

**Architecture:** Ayrı bir Swift Package (`SelfwakeCore`) olarak yazılıyor; ana Xcode uygulaması ve widget/watch hedefleri bu paketi bağımlılık olarak kullanacak. Bu ayrım, saf mantığın (StreakCalculator, hesaplanan özellikler) UI'dan ve platforma özgü çatılardan (SwiftUI, WidgetKit) bağımsız kalmasını sağlıyor.

**Tech Stack:** Swift 6, SwiftData, Swift Testing (`import Testing`, `@Test`/`#expect`).

**Spec:** `docs/specs/2026-09-11-selfwake-mimari.md` (Bölüm 3 "Veri modeli", Bölüm 4.4 "İlerleme / kademeli geri çekilme")

## Global Constraints

- Bu makinede Swift toolchain yok — **hiçbir test bu oturumda çalıştırılmıyor.** Her görevdeki "test çalıştır" adımı yerine bir "doğrulama ertelendi" notu var. İlk gerçek doğrulama, paket bir Xcode projesine/Codemagic hattına bağlandığında toplu yapılacak.
- Tüm public API'ler `public` erişim belirleyicisiyle işaretlenir (ayrı bir hedeften kullanılacak).
- Tarih/saat hesapları `Date`/`TimeInterval` ile yapılır, saat dilimi dönüşümü bu alt sistemde yok (UI katmanı `Calendar`/`TimeZone` ile ilgilenecek).
- Spec'in "ağ tamamen kapatılamaz" kuralı (Bölüm 4.2): `StreakTier.alarmVolumeLevel` hiçbir kademede 0 olamaz.

---

### Task 1: Paket iskeleti

**Files:**
- Create: `Selfwake/SelfwakeCore/Package.swift`
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/.gitkeep` (klasörü var etmek için, ilk gerçek dosya Task 2'de silecek)

**Interfaces:**
- Consumes: yok (ilk görev)
- Produces: `SelfwakeCore` adında derlenebilir bir Swift Package hedefi; sonraki tüm görevler `Sources/SelfwakeCore/` altına dosya ekliyor.

- [ ] **Step 1: `Package.swift` dosyasını yaz**

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SelfwakeCore",
    platforms: [.iOS("26.0")],
    products: [
        .library(name: "SelfwakeCore", targets: ["SelfwakeCore"])
    ],
    targets: [
        .target(name: "SelfwakeCore"),
        .testTarget(name: "SelfwakeCoreTests", dependencies: ["SelfwakeCore"])
    ]
)
```

- [ ] **Step 2: Kaynak ve test klasörlerini oluştur**

`Sources/SelfwakeCore/` ve `Tests/SelfwakeCoreTests/` boş klasörler olarak
oluşturulur (Task 2 ilk dosyayı ekleyince `.gitkeep` gereksiz kalır,
silinir).

- [ ] **Step 3: Doğrulama — ertelendi**

Not: `swift build` bu makinede çalıştırılamıyor (toolchain yok). Paketin
gerçekten derlendiği, `SelfwakeCore` Xcode projesine bağlanıp
Codemagic'te ilk kez build alındığında doğrulanacak.

- [ ] **Step 4: Commit**

```bash
git add Selfwake/SelfwakeCore/Package.swift
git commit -m "chore: SelfwakeCore paket iskeletini kur"
```

---

### Task 2: `Night` modeli

**Files:**
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/Night.swift`
- Test: `Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/NightTests.swift`

**Interfaces:**
- Consumes: yok
- Produces: `public final class Night` — `id: UUID`, `date: Date`,
  `targetTime: Date`, `actualWakeTime: Date?`, `bedTime: Date?`,
  `alarmDidRing: Bool`, `isBlindTest: Bool`, `isBlindDecoy: Bool`,
  `intentSentence: String?`, `freeNote: String?`,
  computed `deviationMinutes: Double?`, computed `isSuccess: Bool?`.
  Task 5 (`StreakCalculator`) ve Task 6 (`ReactionTest` ilişkisi) bu
  tipi kullanır.

- [ ] **Step 1: Başarısız testi yaz**

```swift
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
}
```

- [ ] **Step 2: Doğrulama — ertelendi**

Not: Bu test şu an çalıştırılamıyor; `Night` tipi henüz yok, derleme
hatası beklenir ama teyit edilmiyor (Global Constraints).

- [ ] **Step 3: `Night` modelini yaz**

```swift
import Foundation
import SwiftData

@Model
public final class Night {
    public var id: UUID
    public var date: Date
    public var targetTime: Date
    public var actualWakeTime: Date?
    public var bedTime: Date?
    public var alarmDidRing: Bool
    public var isBlindTest: Bool
    public var isBlindDecoy: Bool
    public var intentSentence: String?
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
        self.freeNote = freeNote
    }

    /// `actualWakeTime - targetTime`, dakika. Pozitif = geç, negatif = erken.
    public var deviationMinutes: Double? {
        guard let actual = actualWakeTime else { return nil }
        return actual.timeIntervalSince(targetTime) / 60
    }

    /// ±30 dakika literatür eşiği (Bölüm 5, "İlerleme").
    public var isSuccess: Bool? {
        guard let d = deviationMinutes else { return nil }
        return abs(d) <= 30
    }
}
```

- [ ] **Step 4: Doğrulama — ertelendi**

- [ ] **Step 5: Commit**

```bash
git add Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/Night.swift \
        Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/NightTests.swift
git commit -m "feat: Night modelini ve sapma/başarı hesaplarını ekle"
```

---

### Task 3: `ReactionTest` modeli

**Files:**
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/ReactionTest.swift`
- Test: `Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/ReactionTestTests.swift`

**Interfaces:**
- Consumes: `Night` (Task 2) — bire-bir ilişki.
- Produces: `public final class ReactionTest` — `id: UUID`,
  `night: Night?`, `timestampsMs: [Double]`, `testDate: Date`, computed
  `averageMs: Double`.

- [ ] **Step 1: Başarısız testi yaz**

```swift
import Testing
import Foundation
@testable import SelfwakeCore

@Suite("ReactionTest ortalama hesabı")
struct ReactionTestTests {
    @Test("Boş dizide ortalama sıfır")
    func averageZeroWhenEmpty() {
        let test = ReactionTest(timestampsMs: [], testDate: .now)
        #expect(test.averageMs == 0)
    }

    @Test("Ortalama doğru hesaplanır")
    func averageComputedCorrectly() {
        let test = ReactionTest(timestampsMs: [200, 300, 400], testDate: .now)
        #expect(test.averageMs == 300)
    }

    @Test("Night ilişkisi atanabilir")
    func nightRelationshipAssignable() {
        let night = Night(date: .now, targetTime: .now)
        let test = ReactionTest(night: night, timestampsMs: [250], testDate: .now)
        #expect(test.night === night)
    }
}
```

- [ ] **Step 2: Doğrulama — ertelendi**

- [ ] **Step 3: `ReactionTest` modelini yaz**

```swift
import Foundation
import SwiftData

@Model
public final class ReactionTest {
    public var id: UUID
    public var night: Night?
    public var timestampsMs: [Double]
    public var testDate: Date

    public init(
        id: UUID = UUID(),
        night: Night? = nil,
        timestampsMs: [Double] = [],
        testDate: Date
    ) {
        self.id = id
        self.night = night
        self.timestampsMs = timestampsMs
        self.testDate = testDate
    }

    public var averageMs: Double {
        timestampsMs.isEmpty ? 0 : timestampsMs.reduce(0, +) / Double(timestampsMs.count)
    }
}
```

- [ ] **Step 4: Doğrulama — ertelendi**

- [ ] **Step 5: Commit**

```bash
git add Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/ReactionTest.swift \
        Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/ReactionTestTests.swift
git commit -m "feat: ReactionTest modelini ve ortalama hesabını ekle"
```

---

### Task 4: `UserSettings` modeli

**Files:**
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/UserSettings.swift`
- Test: `Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/UserSettingsTests.swift`

**Interfaces:**
- Consumes: yok
- Produces: `public final class UserSettings` — spec Bölüm 3 + Bölüm
  4.1/4.5-4.7'de eklenen alanların tümü. Task 5 (`StreakCalculator`)
  `alarmOffsetMinutes`/`alarmVolumeLevel` alanlarını okuyup yazacak
  şekilde tasarlanmalı (tipler burada sabitleniyor: `Int`, `Double`).

- [ ] **Step 1: Başarısız testi yaz**

```swift
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
```

- [ ] **Step 2: Doğrulama — ertelendi**

- [ ] **Step 3: `UserSettings` modelini yaz**

```swift
import Foundation
import SwiftData

@Model
public final class UserSettings {
    public var targetTimeDefault: Date
    public var currentStreak: Int
    public var bestStreak: Int
    /// Ağın hedef saatten kaç dakika sonra çalacağı — Bölüm 4.4, StreakCalculator besler.
    public var alarmOffsetMinutes: Int
    /// 0.0-1.0, asla 0 olmaz (Bölüm 4.2 "tamamen kapatılamaz").
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
    }
}
```

- [ ] **Step 4: Doğrulama — ertelendi**

- [ ] **Step 5: Commit**

```bash
git add Selfwake/SelfwakeCore/Sources/SelfwakeCore/Models/UserSettings.swift \
        Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/UserSettingsTests.swift
git commit -m "feat: UserSettings modelini güvenli varsayılanlarla ekle"
```

---

### Task 5: `StreakCalculator` — kademeli geri çekilme mantığı

**Files:**
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/AlarmEngine/StreakCalculator.swift`
- Test: `Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/StreakCalculatorTests.swift`

**Interfaces:**
- Consumes: `[Bool]` (son 7 gecenin `Night.isSuccess` dizisi, Task 2'den).
- Produces: `public enum StreakTier` (`tier0...tier4`, `alarmOffsetMinutes: Int`,
  `alarmVolumeLevel: Double`) ve
  `public static func StreakCalculator.recompute(lastSevenNights:currentTier:) -> StreakTier`.
  Bu, gelecekteki `AlarmEngine` alt sisteminin `AlarmScheduler`'ı
  besleyeceği arayüz.

- [ ] **Step 1: Başarısız testi yaz**

```swift
import Testing
@testable import SelfwakeCore

@Suite("StreakCalculator kademe geçişleri")
struct StreakCalculatorTests {
    @Test("5/7 başarı bir kademe ilerletir")
    func advancesOnFiveOfSeven() {
        let successes = [true, true, true, true, true, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier1)
        #expect(next == .tier2)
    }

    @Test("En üst kademede daha fazla ilerlemez")
    func staysAtTopTier() {
        let successes = Array(repeating: true, count: 7)
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier4)
        #expect(next == .tier4)
    }

    @Test("2/7 başarı bir kademe geriletir")
    func regressesOnLowSuccess() {
        let successes = [true, true, false, false, false, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier2)
        #expect(next == .tier1)
    }

    @Test("En alt kademede sıfırın altına inmez")
    func neverBelowZero() {
        let successes = Array(repeating: false, count: 7)
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier0)
        #expect(next == .tier0)
    }

    @Test("3/7 ile 4/7 arası nötr bölgede kademe değişmez")
    func neutralZoneNoChange() {
        let successes = [true, true, true, false, false, false, false]
        let next = StreakCalculator.recompute(lastSevenNights: successes, currentTier: .tier2)
        #expect(next == .tier2)
    }

    @Test("Eksik veri (7'den az gece) kademeyi değiştirmez")
    func incompleteDataNoChange() {
        let next = StreakCalculator.recompute(lastSevenNights: [true, true], currentTier: .tier2)
        #expect(next == .tier2)
    }

    @Test("Hiçbir kademede ses seviyesi sıfır değildir")
    func volumeNeverZero() {
        for tier in StreakTier.allCases {
            #expect(tier.alarmVolumeLevel > 0)
        }
    }

    @Test("Kademe yükseldikçe offset artar, ses azalır")
    func tiersAreMonotonic() {
        let tiers = StreakTier.allCases.sorted { $0.rawValue < $1.rawValue }
        for (a, b) in zip(tiers, tiers.dropFirst()) {
            #expect(a.alarmOffsetMinutes < b.alarmOffsetMinutes)
            #expect(a.alarmVolumeLevel > b.alarmVolumeLevel)
        }
    }
}
```

- [ ] **Step 2: Doğrulama — ertelendi**

- [ ] **Step 3: `StreakCalculator`'ı yaz**

```swift
import Foundation

/// Bölüm 4.4'teki kademeli geri çekilme: başarı arttıkça ağ hedef saatten
/// daha geç çalar ve daha kısık sesle çalar; asla tamamen susmaz
/// (Bölüm 4.2, "tamamen kapatılamaz").
public enum StreakTier: Int, CaseIterable {
    case tier0 = 0, tier1, tier2, tier3, tier4

    /// Ağın hedef saatten kaç dakika sonra çalacağı.
    public var alarmOffsetMinutes: Int { rawValue * 3 }

    /// 0.0-1.0, hiçbir kademede sıfır değildir.
    public var alarmVolumeLevel: Double {
        [1.0, 0.75, 0.5, 0.3, 0.15][rawValue]
    }
}

public enum StreakCalculator {
    /// Bir kademe ilerlemek için son 7 gecede en az bu kadar başarı gerekir.
    public static let advanceThreshold = 5
    /// Bunun altında bir kademe geriler; ikisi arası nötr bölgedir.
    public static let regressThreshold = 3

    /// Son 7 gecenin başarı dizisine bakıp bir sonraki kademeyi döner.
    /// Dizi 7 eleman değilse (yetersiz veri) kademe değişmez.
    public static func recompute(lastSevenNights successes: [Bool], currentTier: StreakTier) -> StreakTier {
        guard successes.count == 7 else { return currentTier }
        let successCount = successes.filter { $0 }.count

        if successCount >= advanceThreshold {
            let next = min(currentTier.rawValue + 1, StreakTier.allCases.count - 1)
            return StreakTier(rawValue: next)!
        }
        if successCount < regressThreshold {
            let next = max(currentTier.rawValue - 1, 0)
            return StreakTier(rawValue: next)!
        }
        return currentTier
    }
}
```

- [ ] **Step 4: Doğrulama — ertelendi**

- [ ] **Step 5: Commit**

```bash
git add Selfwake/SelfwakeCore/Sources/SelfwakeCore/AlarmEngine/StreakCalculator.swift \
        Selfwake/SelfwakeCore/Tests/SelfwakeCoreTests/StreakCalculatorTests.swift
git commit -m "feat: StreakCalculator ile kademeli alarm geri çekilmesini ekle"
```

---

### Task 6: App Group SwiftData container

**Files:**
- Create: `Selfwake/SelfwakeCore/Sources/SelfwakeCore/Persistence/SwiftDataContainer.swift`

**Interfaces:**
- Consumes: `Night`, `ReactionTest`, `UserSettings` (Task 2-4).
- Produces: `public enum SwiftDataContainer` — `public static let appGroupID: String`,
  `public static func make() -> ModelContainer`. Ana uygulama, widget
  extension ve watch hedefi hepsi bu fonksiyonu çağırarak **aynı**
  App Group deposuna bağlanacak (Bölüm 1, "App Group ile SwiftData
  paylaşımı").

- [ ] **Step 1: `SwiftDataContainer`'ı yaz**

Bu görevin gerçek testi bir simülatör/Xcode ortamı ve gerçek bir App
Group entitlement'ı gerektiriyor — SwiftData'nın disk G/Ç'si SPM'in
`swift test` ortamında App Group izinleriyle doğrulanamaz. Bu yüzden
test-first atlanıyor, kod doğrudan yazılıyor; doğrulama Task 7'de (Xcode
projesine bağlama) yapılacak.

```swift
import Foundation
import SwiftData

public enum SwiftDataContainer {
    /// Ana uygulama, widget extension ve watch hedefinin `Signing & Capabilities`
    /// bölümünde birebir aynı şekilde tanımlanmış olmalı.
    public static let appGroupID = "group.com.selfwake.app"

    public static func make() -> ModelContainer {
        let schema = Schema([Night.self, ReactionTest.self, UserSettings.self])

        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appending(path: "Selfwake.sqlite")
        else {
            fatalError(
                "App Group konteyneri bulunamadı — \(appGroupID) capability'sinin " +
                "hem ana uygulamada hem widget/watch hedeflerinde açık olduğundan emin ol."
            )
        }

        let configuration = ModelConfiguration(schema: schema, url: groupURL)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData container kurulamadı: \(error)")
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Selfwake/SelfwakeCore/Sources/SelfwakeCore/Persistence/SwiftDataContainer.swift
git commit -m "feat: App Group SwiftData container kurulumunu ekle"
```

---

### Task 7: Codemagic doğrulama notu (kod değil, kayıt)

**Files:**
- Modify: `docs/specs/2026-09-11-selfwake-mimari.md` (Bölüm 9'a tek satırlık ilerleme notu)

**Interfaces:**
- Consumes: Task 1-6'nın tamamı.
- Produces: Spec dosyasında "Temel alt sistemi kod olarak yazıldı, ilk
  gerçek derleme/test doğrulaması bekliyor" notu — bir sonraki oturumda
  nereden devam edileceğini işaretler.

- [ ] **Step 1: Spec'e ilerleme notu ekle**

Bölüm 9'un başına şu satır eklenir: "**Durum (11 Eylül 2026):** Temel
alt sistemi (`SelfwakeCore` paketi — Night, ReactionTest, UserSettings,
StreakCalculator, SwiftDataContainer) koda döküldü; hiçbir test bu
makinede çalıştırılmadı. İlk doğrulama, paket bir Xcode projesine
bağlanıp Codemagic'te derlendiğinde yapılacak."

- [ ] **Step 2: Commit**

```bash
git add docs/specs/2026-09-11-selfwake-mimari.md
git commit -m "docs: Temel alt sisteminin durumunu spec'e işle"
```
