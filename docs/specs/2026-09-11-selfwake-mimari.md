# Selfwake ("Ağ") — Mimari ve Ekran Akışı Spesifikasyonu

> Bu belge kod yazılmadan önceki mimari onay adımıdır. Onaylandıktan sonra
> her alt sistem için `superpowers:writing-plans` ile ayrı, bite-sized
> TDD implementasyon planı yazılacak (bkz. sondaki "Sıradaki adım").

**Uygulama adı:** Selfwake (marka adı İngilizce ve Türkçe'de aynı kalır)
- EN alt başlık: *"Train your brain to wake up on time, without an alarm."*
- TR alt başlık: *"Alarmsız, tam zamanında uyanmayı beyninize öğretin."*

**Vaat:** Alarmsız uyanmayı öğretir; amacı kendini gereksiz kılmaktır.

**Platform:** iOS 26+, Swift 6, SwiftUI, saf native (AlarmKit'in native
olması nedeniyle Flutter/React Native elenir).

---

## 1. Teknoloji yığını

| Katman | Seçim | Neden |
| --- | --- | --- |
| UI | SwiftUI | AlarmKit ve WidgetKit'in birinci sınıf desteklediği katman |
| Kalıcılık | SwiftData | Sunucu yok, tek cihaz, ilişkisel modelleme yeterince basit |
| Alarm | AlarmKit | Sessiz modu ve Odak'ı delen tek native yol |
| Sağlık verisi | HealthKit (yalnız okuma) | Uyku/nabız, yalnızca kullanıcı açarsa |
| Widget | WidgetKit + App Intents | Ana ekran + kilit ekranı, App Group ile SwiftData paylaşımı |
| Canlı durum | ActivityKit (Live Activity) | Kilit ekranında gece boyunca hedef saate kalan süre |
| Sesli komut | App Intents (Siri kısayolları) | "Hey Siri, gece ritüelimi başlat" |
| Takvim | EventKit (yalnız okuma) | Niyet cümlesi için "ertesi günün ilk işi"ni otomatik çeker |
| Bilek cihazı | watchOS companion + AlarmKit (watchOS tarafı) | Sessiz titreşimle güvenlik ağı, yatak paylaşan biri uyanmaz |
| Yapay zekâ | Foundation Models framework (on-device) | Ücretsiz, gizlilik bozmaz; yoksa kural tabanlı metne düş |
| Abonelik | StoreKit 2 | Sunucu yok, `Transaction.currentEntitlements` ile yerel doğrulama |
| Grafikler | Swift Charts | Sapma/tepki süresi grafikleri |
| Yerelleştirme | String Catalog (`.xcstrings`) | tr (birincil) + en |

**Sunucu yok, hesap yok, giriş yok.** Tüm veri cihazda; App Group yalnızca
ana uygulama ↔ widget extension arasında SwiftData deposunu paylaşmak için.

### 1.1 Apple hesabı tarafında hazır olanlar (11 Eylül 2026)

Plasebo ile aynı takım (`Rahile KÖKDOĞAN`, `ML3UZXMU3D`) üzerinde kuruldu —
ayrı bir Apple Developer üyeliği gerekmedi.

| Ne | Değer |
| --- | --- |
| Ana uygulama App ID | `com.selfwake.app` — App Groups + HealthKit açık |
| Widget App ID | `com.selfwake.app.SelfwakeWidget` — App Groups açık |
| Watch App ID | `com.selfwake.app.watchkitapp` — App Groups açık |
| App Group | `group.com.selfwake.app` — üç App ID'ye de bağlandı |
| App Store Connect uygulaması | **Selfwake**, Apple ID `6811170233`, durum "Prepare for Submission" |
| SKU | `selfwake-ios-1` |
| Birincil dil (App Store Connect) | Türkçe |

**AlarmKit için App ID'de ayrı bir capability yok** — geliştirici
portalının "Capabilities" ve "App Services" listelerinde "Alarm" araması
sonuç vermedi; framework'ün Xcode'da yalnızca `import AlarmKit` ve
`NSAlarmKitUsageDescription` ile çalıştığı anlaşılıyor. Codemagic'te ilk
derlemede bu doğrulanacak.

**Yapılmayanlar:** TestFlight Test Bilgisi, abonelik ürünleri,
Codemagic bağlantısı — bunlar Xcode projesi (Bölüm 1.2) hazır olduktan
sonra sırayla yapılacak.

---

## 2. Açık teknik riskler (kodlamadan önce doğrulanmalı)

Bunlar mimariyi etkileyebileceği için ayrı bir **araştırma spike'ı**
olarak Task 0'da netleştirilmeli; aşağıdaki sayılar/isimler taslak,
Apple'ın güncel AlarmKit/Foundation Models dokümantasyonuyla teyit
edilmeden koda geçilmeyecek:

1. **AlarmKit eşzamanlı alarm limiti** — **kısmen araştırıldı (11 Eylül
   2026, topluluk kaynakları):** resmi bir sayı bulunamadı. Selfwake zaten
   uygulama başına yalnızca **tek** aktif alarm kuruyor (o geceki güvenlik
   ağı), bu yüzden pratikte risk düşük; yine de Codemagic'te ilk gerçek
   derlemede Apple'ın resmi dokümantasyonuyla teyit edilecek.
2. **AlarmKit yetkilendirme akışı** — **doğrulandı:**
   `NSAlarmKitUsageDescription` Info.plist anahtarı gerekiyor,
   `AlarmManager.shared.authorizationState` (`.notDetermined/.authorized/
   .denied`) ve `AlarmManager.shared.requestAuthorization()` ile akış
   `AlarmPermissionManager.swift`'te kodlandı (Temel'den sonraki
   AlarmEngine görevi). Kullanıcı reddederse yedek moda geçiş kararı
   henüz UI katmanında yazılmadı — Gece Ritüeli alt sisteminde ele
   alınacak.
3. **Foundation Models kullanılabilirlik kontrolü** —
   `SystemLanguageModel.default.availability` dönen durumları (cihaz
   uygun değil / Apple Intelligence kapalı / model hazır değil) üç
   ayrı kullanıcı mesajına mı eşlenecek yoksa tek bir "kural tabanlı
   moda düş" mü olacak — Task 0'da karara bağlanacak.
4. **watchOS'ta AlarmKit** — güvenlik ağının bilekte sessiz titreşimle
   çalması için AlarmKit'in watchOS companion'daki karşılığı (aynı API mi,
   ayrı bir yol mu) doğrulanmalı. Doğrulanamazsa yedek: telefon alarmı
   çalar, `WatchConnectivity` üzerinden Watch'a yalnızca titreşim
   komutu gönderilir (Watch kendi başına alarm kurmaz).
5. **ActivityKit bütçesi** — Live Activity'nin gece boyunca (7-9 saat)
   canlı kalabilmesi; sistem `Activity` süresini kısıtlayabilir, gerekirse
   periyodik yenileme (`ActivityKit` push olmadan, yerel zamanlayıcıyla)
   tasarlanmalı.
6. **AlarmKit ses seviyesi kontrolü** — `StreakTier.alarmVolumeLevel`
   (Bölüm 4.4) alarmın kademeli kısılmasını varsayıyor, ama
   `AlarmScheduler.swift`'te bu değer şu an **uygulanmıyor** — AlarmKit'in
   sesi programatik ayarlayan bir API'si topluluk kaynaklarında
   görülmedi. Codemagic'te ilk derlemede Apple dokümantasyonuyla teyit
   edilecek; bulunamazsa yedek: `AlarmPresentation`'ın kendi ayarları ya
   da sistemin genel ses seviyesine bırakma.

---

## 3. Veri modeli (SwiftData)

```swift
@Model
final class Night {
    var id: UUID
    var date: Date                     // gecenin takvim günü (ritüelin yapıldığı akşam)
    var targetTime: Date                // hedeflenen uyanma saati
    var actualWakeTime: Date?           // uygulamanın ilk açıldığı an (alarm ya da erken açılış)
    var bedTime: Date?                  // opsiyonel, HealthKit'ten ya da elle
    var alarmDidRing: Bool              // güvenlik ağı gerçekten çaldı mı
    var isBlindTest: Bool               // bu gece kör test kapsamında mı
    var isBlindDecoy: Bool              // kör testin "sahte" (boş bekleme) gecesi mi
    var intentSentence: String?         // AI ya da kural tabanlı niyet cümlesi
    var firstActionWord: String?        // Adım 3: uyanınca ilk yapılacak şey (tek kelime)
    var freeNote: String?               // kullanıcının serbest notu

    var deviationMinutes: Double? {     // actualWakeTime - targetTime, dakika
        guard let actual = actualWakeTime else { return nil }
        return actual.timeIntervalSince(targetTime) / 60
    }
    var isSuccess: Bool? {              // ±30 dk literatür eşiği
        guard let d = deviationMinutes else { return nil }
        return abs(d) <= 30
    }
}

@Model
final class ReactionTest {
    var id: UUID
    var night: Night?                   // ilişki: hangi sabaha ait
    var timestampsMs: [Double]          // her dokunuşun tepki süresi
    var testDate: Date
    var averageMs: Double {
        timestampsMs.isEmpty ? 0 : timestampsMs.reduce(0, +) / Double(timestampsMs.count)
    }
}

@Model
final class UserSettings {
    var targetTimeDefault: Date
    var currentStreak: Int
    var bestStreak: Int
    var alarmOffsetMinutes: Int         // başarı arttıkça ağ geriye kayar
    var alarmVolumeLevel: Double        // 0.0–1.0, başarı arttıkça kısılır
    var blindTestEnabled: Bool
    var healthKitEnabled: Bool
    var themeID: String                 // Bölüm 6, ThemeManager anahtarı
    var reduceMotionOverride: Bool?     // nil = sistem ayarını izle
    var onboardingCompleted: Bool
    var breathSoundEnabled: Bool        // Adım 2'nin isteğe bağlı sesi, varsayılan false
    var calendarEnabled: Bool           // EventKit okuma izni verildi mi
    var watchCompanionEnabled: Bool     // eşleşmiş Watch üzerinden titreşim
    var liveActivityEnabled: Bool       // varsayılan true, kullanıcı kapatabilir
    var reminderEnabled: Bool           // Bölüm 4.8, varsayılan true
    var reminderTime: Date              // yalnız saat/dakika okunur
}
```

**İlişki notu:** `Night ↔ ReactionTest` bire-bir; test her zaman bir
geceye bağlı çünkü sabah özeti ikisini birlikte okuyor.

**Kademeli geri kayma mantığı** (Bölüm 4.4'teki "İlerleme" akışını besler):
`alarmOffsetMinutes` ve `alarmVolumeLevel`, son N gecenin `isSuccess`
oranına göre haftalık olarak güncellenir — bu hesap ayrı bir
`StreakCalculator` servisinde yaşar, View içine gömülmez (test edilebilir
olması için).

---

## 4. Dosya yapısı

> **Uygulama notu (Temel alt sisteminden itibaren):** UI'sız, test edilebilir
> her şey (`Models/`, `Persistence/`, `AlarmEngine/` içindeki saf mantık,
> `NightRitual/`'ın state machine'i) gerçekte ayrı bir SPM paketinde —
> `Selfwake/SelfwakeCore/Sources/SelfwakeCore/<aşağıdaki yol>`. Aşağıdaki
> ağaç mantıksal grupları gösteriyor; SwiftUI View'lar (`NightRitual/*View.swift`
> gibi) yine ana uygulama hedefinde kalıyor ve `import SelfwakeCore` ile bu
> pakete bağlanıyor.

```
Selfwake/
  App/
    SelfwakeApp.swift              — @main, SwiftData ModelContainer (App Group)
    RootView.swift                  — UserSettings var mı bakar; yoksa oluşturur,
                                       onboardingCompleted'a göre Onboarding/Bugün seçer
  Home/
    TodayView.swift                 — hedef saat, seri, "Gece Ritüelini Başlat"
  Models/
    Night.swift, ReactionTest.swift, UserSettings.swift
  Persistence/
    SwiftDataContainer.swift        — App Group container kurulumu
  AlarmEngine/
    AlarmScheduler.swift            — AlarmKit sarmalayıcı
    AlarmPermissionManager.swift
    AlarmSchedulingDecision.swift   — SelfwakeCore'da: erken uyanma/çalma saati, saf mantık
    StreakCalculator.swift          — offset/ses kademesi hesaplayan saf mantık
  NightRitual/                      — state machine SelfwakeCore'da (bkz. aşağı), View'lar burada
    TargetTimeConfirmView.swift
    IntentStep1View.swift           — saati söyle
    IntentStep2View.swift           — 5 saniyelik canlandırma + opsiyonel nefes sesi
    IntentStep3View.swift           — tek kelime, RitualCoordinator.setFirstActionWord çağırır
    RitualFadeOutView.swift         — Bölüm 4.3'teki kararma ekranı
    BreathSoundPlayer.swift         — Adım 2'nin isteğe bağlı sesi, varsayılan kapalı
  BlindTest/                        — atama mantığı (BlindTestScheduler) SelfwakeCore'da
    BlindWaitingView.swift          — niyet protokolü yerine boş bekleme
  MorningTest/                      — oturum/karşılaştırma mantığı SelfwakeCore'da (bkz. yukarı)
    ReactionTestView.swift          — 30 sn PVT-lite, ReactionTestSession'ı sarar
    MorningSummaryView.swift        — MorningSummary.reactionTimeDeltaMs'i okur
  Progress/                         — ProgressStats + BlindTestComparison SelfwakeCore'da
    StatsView.swift                 — ProgressStats.successRate/hasSilentWeekBadge'i okur
    DriftChartView.swift            — Swift Charts, ProgressStats.driftSeries'i çizer
    BlindTestComparisonView.swift   — BlindTestComparison.compare sonucunu gösterir, gizlemez
    PatternInsightView.swift        — AI/kural tabanlı haftalık özet
  Widgets/
    SelfwakeWidgetBundle.swift
    LockScreenWidget.swift
    HomeScreenWidget.swift
    WidgetTimelineProvider.swift
  LiveActivity/
    NightActivityAttributes.swift   — ActivityKit özniteliği (hedef saat, kalan süre)
    NightLiveActivityView.swift     — kilit ekranı sunumu
    LiveActivityController.swift    — ritüel bitince başlatır, sabah testinde bitirir
  Intents/
    StartRitualIntent.swift         — App Intents, "Gece ritüelimi başlat"
    OpenTodayIntent.swift           — App Intents, Ana Ekran'ı açar
  Calendar/
    EventKitReader.swift            — salt okunur, yalnız izin verilirse
    NextDayFirstEventResolver.swift — niyet cümlesi Adım 3'e öneri besler
  Watch/
    SelfwakeWatchApp.swift          — companion hedef, @main
    WatchAlarmRelay.swift           — Bölüm 2 madde 4'teki spike'a göre AlarmKit ya da
                                       WatchConnectivity titreşim komutu
    WatchComplication.swift         — hedef saat / seri sayısı
  Intelligence/
    IntelligenceAvailability.swift  — Foundation Models durum enum'u
    IntentPhraseGenerator.swift
    MorningCommentGenerator.swift
    WeeklyPatternSummarizer.swift
    JournalThemeExtractor.swift
    AdaptiveTargetTimeAdvisor.swift — Bölüm 8'deki hedef saat önerisi
    EveningRiskWarningGenerator.swift — Bölüm 8'deki akşamdan risk uyarısı
    ToneAdapter.swift               — serbest notlardan ton öğrenimi
    RuleBasedFallbacks.swift        — model yokken kullanılan şablonlar
  Health/
    HealthKitReader.swift
  Subscription/
    StoreKitManager.swift
    PaywallView.swift
  Onboarding/                       — sıra OnboardingCoordinator'da (SelfwakeCore), 7 adım
    OnboardingFlowView.swift        — adıma göre ekranı seçer, geri/devam düğmeleri
    WelcomeStep.swift                — vaat birebir
    HowItWorksStep.swift            — dört maddelik döngü
    ScienceStep.swift               — kaynakçalı bilimsel temel
    HonestyStep.swift
    PermissionsStep.swift           — Alarm, Bildirim, Sağlık (opsiyonel)
    ReminderSetupStep.swift         — Bölüm 4.8, saat/dakika seçimi
    TargetTimeSetupStep.swift
  Reminders/                        — RitualReminderCalculator + NotificationScheduling SelfwakeCore'da
    (app tarafında ek View yok; Ayarlar'daki aç/kapat SettingsView'a dahil)
  Settings/
    SettingsView.swift
    ThemeManager.swift
    DataDeletionView.swift
  Shared/
    Theme.swift                     — Bölüm 6
    MotionPreference.swift          — Reduce Motion okuma
    Haptics.swift
  Resources/
    Localizable.xcstrings           — tr + en
    InfoPlist.xcstrings             — CFBundleDisplayName, açıklamalar
SelfwakeWidgetExtension/            — ayrı hedef, Widgets/ + LiveActivity/ dosyalarını paylaşır
SelfwakeWatchApp/                   — ayrı hedef (watchOS), Watch/ dosyalarını içerir
```

### 4.1 Gece ritüeli (uygulamanın kalbi)

`RitualCoordinator` tek yönlü bir state machine: `.confirmTime → .step1 →
.step2 → .step3 → .fadeOut`. Her adımda:

- Ekranda **tek** öğe: büyük rakam, animasyon ya da tek kelimelik giriş.
- Liste yok, açıklama paragrafı yok — bu kısıt View seviyesinde değil,
  `RitualCoordinator`'ın her state'inin yalnızca bir `primaryContent`
  döndürmesiyle zorlanır (View'lar ek içerik ekleyemez).
- Karanlık zemin + düşük parlaklık: `Theme` içinde ritüel ekranlarına özel
  sabit bir "ritual" varyantı var, kullanıcının seçtiği temadan bağımsız
  (yatakta, uykulu gözle okunabilirlik önceliği).
- Adım 2 (5 sn canlandırma): `MotionPreference.reduceMotion == true` ise
  animasyon yerine 5 saniyelik statik bir nefes/duraklama ekranı — **içerik
  kaybolmaz**, yalnızca hareket kaybolur (spec'in "Hareketi Azalt" kuralı).
- Adım 2'ye eşlik eden **opsiyonel nefes sesi** (`BreathSoundPlayer`):
  varsayılan kapalı, Ayarlar'dan `breathSoundEnabled` ile açılır. Sessiz
  moddayken bile ses profilinde `.ambient` kategori kullanılır — telefonu
  yanında uyuyan biri varsa aniden yükselmez.

### 4.2 Güvenlik ağı

- `AlarmScheduler`, `RitualCoordinator` `.fadeOut`'a geçtiğinde hedef
  saate `AlarmKit` alarmı kurar.
- Kullanıcı hedef saatten önce uygulamayı açarsa (`AppRouter` bunu
  `Night.actualWakeTime` alanına yazar), `AlarmScheduler.cancelIfEarly()`
  çağrılır — alarm hiç çalmaz.
- Ağ **tamamen kapatılamaz**: Ayarlar'da yalnızca `alarmVolumeLevel`
  (kademeli kısılma) ayarlanabilir, sıfıra hard-cap yoktur; UI'da alarm
  aç/kapat anahtarı hiç sunulmaz.
- **Watch companion** (`watchCompanionEnabled` açıksa): `WatchAlarmRelay`
  hedef saatte telefonla birlikte ya da (Bölüm 2 madde 4'teki spike'ın
  sonucuna göre) onun yerine bilekte sessiz bir titreşim üretir. Amaç
  aynı yatağı paylaşan birinin uyanmaması; bu yüzden Watch'taki uyarı ses
  çıkarmaz, yalnızca titreşir. Telefon alarmı yine de kurulur — Watch
  bağlantısı koparsa (uçak modu, menzil dışı) güvenlik ağı boşta kalmaz.

### 4.3 Ritüelin bitişi

Spesifikasyonun önceki taslağı "ekran kararır, uygulama kendini kapatır"
diye bir vaat içeriyordu; bu vaat **kaldırıldı** — iOS uygulamaları
kendilerini sonlandıramaz (App Store kuralı ve sandbox kısıtı), yani hiç
tutulamayacak bir söz olurdu. Yerine geçen, sözü olmayan bir UX:

1. `RitualFadeOutView` ekranı 2 saniyede tam siyaha söndürür.
2. Hiçbir buton, metin ya da gezinme öğesi göstermez — ritüel burada
   biter, uygulama hakkında bir iddia taşımaz.
3. Kullanıcı isterse ekranı kilitleyip telefonu bırakır; uygulama arka
   plana düşünce sistem zaten askıya alır. Bırakmazsa da ekran siyah
   kalmaya devam eder, hiçbir şey kullanıcıyı ileri itmez.
4. Bir sonraki açılışta (gece yarısını geçtiyse) `AppRouter` otomatik
   olarak Ana Ekran'a değil, sabah akışına yönlendirir.

Onboarding'deki tek cümlelik yönlendirme de vaat değil, yalnızca bir
öneri: "Son adımdan sonra ekranı kilitleyip telefonu bırakabilirsin."

### 4.4 İlerleme / kademeli geri çekilme

`StreakCalculator.recompute(lastNNights:)` haftalık çağrılır (uygulama
her açıldığında son çağrıdan 7+ gün geçtiyse tetiklenir):

- Son 7 gecenin `isSuccess` oranı ≥ eşik ise `alarmOffsetMinutes` artar
  (ağ hedef saatten daha az önce/daha geç devreye girer) ve
  `alarmVolumeLevel` bir kademe azalır.
- Oran düşerse değerler bir önceki kademeye geri döner (asla sıfıra
  düşmez — Bölüm 4.2'deki "tamamen kapatılamaz" kısıtıyla tutarlı).
- Hedef: `alarmVolumeLevel` minimuma inip art arda 7 gece `alarmDidRing
  == false` olması — bu UI'da özel bir rozetle kutlanır.

### 4.5 Live Activity

`LiveActivityController`, `RitualCoordinator` `.fadeOut`'a geçtiğinde
(`liveActivityEnabled` açıksa) bir `Activity<NightActivityAttributes>`
başlatır: kilit ekranında hedef saate kalan süreyi gösterir. Sabah testi
bitince (`MorningSummaryView` göründüğünde) `Activity.end(...)` ile
kapatılır — hiçbir gece yarısından sonra ekranda asılı kalmaz. Bölüm
2 madde 5'teki spike, sistemin izin verdiği canlı kalma süresini
doğrulayana kadar bu kapatma ekstra bir güvenlik: `AlarmScheduler`
alarmı çaldığında da (kullanıcı dokunmasa bile) Activity'yi kapatır.

### 4.6 Siri kısayolları

`StartRitualIntent` ve `OpenTodayIntent` (`AppIntent` protokolü),
`RitualCoordinator` ve `AppRouter`'ı doğrudan çağırır — View katmanını
atlamaz, aynı state machine'den geçer. Böylece "Hey Siri, gece ritüelimi
başlat" ile uygulama içinden dokunarak başlatmak arasında davranış farkı
olmaz. Sistem önerileri (`ShortcutsProvider`) akşam saatlerinde bu
intent'i önceliklendirir.

### 4.7 Takvim okuma (EventKit)

`calendarEnabled` açıksa `EventKitReader`, ertesi günün ilk etkinliğini
okur; `NextDayFirstEventResolver` bunu Adım 3'ün ("uyanınca ilk yapacağın
şeyi tek kelimeyle yaz") **önerisi** olarak sunar — kullanıcı yine de
kendi kelimesini yazabilir, alan asla otomatik doldurulup kilitlenmez.
İzin reddedilirse ya da etkinlik yoksa Adım 3 bugünkü gibi boş başlar.
Bu veri aynı zamanda Bölüm 8'deki niyet cümlesi üretimine girdi olur.

### 4.8 Hatırlatıcı bildirimi

Güvenlik ağı (Bölüm 4.2) *reaktif* — yalnızca hedef saatte, erken
uyanılmadıysa çalar. Hatırlatıcı bundan tamamen ayrı ve **proaktif**: her
gece aynı saatte tekrarlayan yerel bir bildirimle "ritüele başlama
vakti" hatırlatır. Sunucu gerektirmez, push değil — yalnızca
`UNUserNotificationCenter` yerel bildirimi.

- `RitualReminderCalculator.defaultReminderTime` varsayılanı önerir
  (hedef saatten 8 saat önce, tipik uyku süresi); onboarding'de
  (Bölüm 5, adım 6) kullanıcı bunu elle değiştirebilir, `UserSettings.
  reminderTime`'da saklanır.
- `NotificationScheduling` protokolü (SelfwakeCore) ile
  `UNRitualReminderScheduler` gerçek uygulaması, `AlarmScheduling`
  ayrımıyla aynı gerekçeyle ayrılmış: framework çağrıları izole, geri
  kalan kod etkilenmez.
- Bildirim gövdesi o geceki hedef saati gösterir ("Bu gece 07:00
  hedefliyorsun. İki dakikanı ayır.") — jenerik bir metin değil.
- `UserSettings.reminderEnabled` (varsayılan `true`) Ayarlar'dan
  kapatılabilir; kapatılınca `cancelReminder()` çağrılır, hedef saat
  değiştiğinde de gövde metni güncellenmek üzere yeniden kurulur.
- Bu bildirim güvenlik ağının **yedeği değil** — ağ hatırlatıcıdan
  bağımsız olarak her zaman kurulur (Bölüm 4.2, "tamamen kapatılamaz").

---

## 5. Ekran akışı (uçtan uca)

1. **Onboarding** (yalnız ilk açılış — `OnboardingCoordinator`, 7 adım,
   geri gidilebilir; Ritüel'in aksine burada "geri" var çünkü uyarıyı ya
   da bilimsel temeli tekrar okumak isteyen biri engellenmemeli)
   1. **Karşılama** — vaat birebir: *"Sabahları yorgun uyanmayın. Alarm
      kurmayı bırakın — beyninizde çalan sese güvenin."* + tek cümlelik
      amaç: kendini gereksiz kılmak.
   2. **Nasıl çalışır** — dört maddelik döngü: Gece (niyet ritüeli) →
      Güvenlik ağı (erken uyanırsan çalmaz) → Sabah (tepki testi) →
      Zamanla (güvenlik ağı geri çekilir). "Ağ" burada **internet**
      değil, sirk cambazının altındaki **emniyet ağı** — seni
      alarmsız uyanma başarısız olursa yakalayan yedek. Kısaltılmış
      "ağ" hiçbir kullanıcı metninde tek başına geçmez; her zaman
      "güvenlik ağı" olarak yazılır (bkz. Bölüm 4.2).
   3. **Bilimsel temel** — kaynakçalı özet (Born ve ark. 1999; Ikeda &
      Hayashi 2014).
   4. **Dürüstlük uyarısı** — herkes yapamaz, düzensiz hedef uykuyu bozar.
   5. **İzinler** — Alarm (zorunlu), Bildirim (hatırlatıcı için, Bölüm
      4.8), Sağlık (opsiyonel, Ayarlar'a ertelenebilir).
   6. **Ritüel hatırlatıcısı** — saat/dakika seçimi,
      `RitualReminderCalculator.defaultReminderTime` (hedeften 8 saat
      önce) öneriyle başlar.
   7. **İlk hedef saat** — "Selfwake'i başlat" ile `onboardingCompleted`
      `true` olur, hatırlatıcı kurulur, Ana Ekran'a geçilir.

2. **Ana Ekran (Bugün)**
   Bu geceki hedef saat, seri sayısı, "Gece Ritüelini Başlat" (akşam
   saatlerinde öne çıkar), dünkü gecenin özet kartı.

3. **Gece Ritüeli** → Bölüm 4.1.

4. **Kör test gecesi** (yalnız Ayarlar'dan açıksa, rastgele gecelerde)
   Niyet protokolü yerine `BlindWaitingView`: aynı toplam süre, aynı
   geçiş hızı, boş bekleme. Hangi gecenin sahte olduğu sabaha kadar
   hiçbir yerde gösterilmez.

5. **Güvenlik ağı çalışması** → AlarmKit'in sistem sunumu (alert +
   ses), kullanıcı dokunup açar → doğrudan Sabah Tepki Testi'ne yönlenir.

6. **Sabah Tepki Testi**: 30 sn, ekran rengi değişince dokun, tepki
   süreleri `ReactionTest`'e yazılır.

7. **Sabah Özeti**: hedef/gerçek saat, sapma, ortalama tepki süresi,
   dünle fark + AI ya da kural tabanlı tek cümlelik yorum.

8. **İlerleme** (çoğu alt bölüm Plus): seri, sapma grafiği, tepki süresi
   trendi, değişken analizi, kör test karşılaştırması, haftalık AI özeti.
   Kör test karşılaştırması fark küçükse bunu **gizlemez** — grafikte
   olduğu gibi gösterilir.

9. **Ayarlar**: hedef saat varsayılanı, tema, Hareketi Azalt override,
   HealthKit aç/kapat, kör test aç/kapat, "Nasıl çalışır" kaynakça,
   abonelik yönetimi, tek dokunuşla tüm veriyi kalıcı silme (çift onaylı).

10. **Paywall**: İlerleme'nin gated alt bölümlerine girişte, kör testi
    açmaya çalışırken, AI yorumlarına dokunulduğunda tetiklenir. Aylık +
    yıllık, bir hafta ücretsiz deneme, StoreKit 2.

**Ücretsiz kalan çekirdek:** Gece ritüeli ve güvenlik ağı sonsuza kadar
ücretsiz — paywall bu ikisinin akışına asla girmez.

---

## 6. Temalar

`Theme` protokolü: arka plan gradyanı, vurgu rengi, metin rengi, ritüel
varyantının sabit koyu paleti (Bölüm 4.1'de not edildi, temadan bağımsız).

| Tema | Kimlik | Karakter |
| --- | --- | --- |
| Gece Mavisi *(varsayılan)* | `nightBlue` | Koyu lacivert zemin, soft mavi vurgu |
| Kömür | `charcoal` | Saf siyah (OLED), donuk amber vurgu — yatak odasında en az ışık |
| Şafak | `dawn` | Koyu mürdüm→turuncu gradyan, gün doğumu hissi |
| Orman | `forest` | Koyu yeşil/turkuaz, sakin |
| Öğlen *(tek açık tema)* | `daylight` | Gündüz İlerleme ekranını kontrol edenler için açık zemin |

`ThemeManager: ObservableObject`, seçim `UserSettings.themeID`'de saklanır,
`.environment(\.selfwakeTheme, ...)` ile dağıtılır. Ritüel ekranları
(`NightRitual/*`) bu environment'ı **okumaz**, sabit koyu paleti kullanır.

---

## 7. Yerelleştirme ve marka adı

- `CFBundleDisplayName`: her iki dilde de **Selfwake** (marka sabit).
- App Store alt başlığı/açıklaması dile göre değişir (Bölüm başındaki
  EN/TR cümleler).
- Tüm uygulama içi metin `Localizable.xcstrings` üzerinden; tr birincil
  kaynak dil (geliştirme dili), en ikincil.
- Bilimsel kaynakça (`ScienceView`) iki dilde de aynı atıfları taşır
  (Born ve ark. 1999; Ikeda & Hayashi 2014) — çeviri atıf metnini
  değiştirmez, yalnızca çevre cümleleri çevirir.

---

## 8. Yapay zekâ katmanı — davranış sözleşmesi

`IntelligenceAvailability` üç duruma eşlenir: `.available`,
`.unavailable(reason)`, `.checking`. Her üretici servis
(`IntentPhraseGenerator`, `MorningCommentGenerator`, ...) önce bu durumu
sorar; `.unavailable` ise **aynı arayüzden** `RuleBasedFallbacks`
çağrılır — View katmanı hangi kaynaktan geldiğini bilmez/bilmemeli (tek
protokol: `SentenceGenerating`).

- **Niyet cümlesi**: hedef saat + ertesi günün ilk işi (kullanıcı elle
  girer ya da Bölüm 4.7'deki takvim önerisinden gelir, opsiyonel) + son
  7 günün başarı oranına bakar. `ToneAdapter` varsa (bkz. aşağı) üretilen
  cümlenin tonunu buradan alır.
- **Sabah yorumu**: sapma + tepki süresi + yatış saatini birlikte okur.
- **Haftalık desen özeti**: Plus, `Night` + `ReactionTest` geçmişinden
  korelasyon çıkarır (basit: yatış saati bucket'larına göre ortalama
  sapma karşılaştırması — gerçek istatistiksel test değil, düz Türkçe
  gözlem).
- **Serbest not analizi**: Plus, tekrar eden kelime/temaları sayar.
- **Adaptif hedef saat önerisi** (`AdaptiveTargetTimeAdvisor`) — son
  7-14 gecenin gerçek uyanma saatlerine (ve varsa HealthKit uyku
  verisine) bakıp "hedefini 15 dk öne almayı dene" gibi tek cümlelik,
  **yalnızca öneri** niteliğinde bir kart Ana Ekran'da belirir. Hedefi
  asla otomatik değiştirmez — kullanıcı elle onaylar.
- **Akşamdan risk uyarısı** (`EveningRiskWarningGenerator`) — yatış
  saati her zamankinden geç olduğunda Ana Ekran'da (ritüel akışının
  *dışında*, ritüelin "tek adım tek şey" kuralını bozmadan) "Bu gece
  ağın çalma ihtimali yüksek" gibi tek cümlelik nazik bir uyarı kartı.
- **Niyet cümlesinin ton öğrenmesi** (`ToneAdapter`) — kullanıcının son
  birkaç serbest notunu `LanguageModelSession`'a bağlam olarak verip
  (few-shot, ayrı bir model eğitimi değil) üretilen cümlelerin dilini
  kullanıcının kendi diline (resmi/samimi) yaklaştırır. Not yoksa ya da
  model kullanılamıyorsa sessizce nötr tona düşer — davranış farkı
  kullanıcıya hissettirilmez.

Guided Generation (`@Generable`) ile çıktı şekli sabitlenir; tıbbi/tedavi
ima eden ifadeler sistem talimatında açıkça yasaklanır. Her yeni üretici
de aynı `SentenceGenerating` protokolüne ve `.unavailable` fallback
kuralına uyar; View katmanı hangi üreticinin AI mı kural tabanlı mı
çalıştığını bilmez.

---

## 9. Kapsam bölünmesi — sıradaki adım

**Durum (11 Eylül 2026):** Temel (Night, ReactionTest, UserSettings,
StreakCalculator, SwiftDataContainer), AlarmEngine (AlarmScheduler,
AlarmPermissionManager, AlarmSchedulingDecision — AlarmKit API'si
topluluk kaynaklarıyla doğrulandı, Bölüm 2 güncellendi) ve Gece Ritüeli'nin
state machine çekirdeği (RitualState, RitualCoordinator, RitualCompletion)
koda döküldü, hepsi `SelfwakeCore` paketinde. Bu sırada `Night` modeline
eksik olan `firstActionWord` alanı eklendi (Bölüm 3 güncel). Gece
Ritüeli, Sabah akışı, Kör Test (`BlindTestScheduler`) ve İlerleme
(`ProgressStats`, `BlindTestComparison`) alt sistemlerinin **saf mantığı**
tamam; hiçbirinin SwiftUI View'ı henüz yazılmadı — Xcode/SwiftUI
önizlemesi olmadan tasarım kalitesi doğrulanamayacağı için bilinçli
olarak ertelendi. Hiçbir test bu makinede çalıştırılmadı (Swift
toolchain yok); ilk doğrulama paket bir Xcode projesine bağlanıp
Codemagic'te derlendiğinde yapılacak. Kalan alt sistemler (Widgets, Live
Activity, Intelligence, HealthKit, Takvim, Siri, Watch, Abonelik,
Onboarding/Ayarlar/Tema) framework-ağırlıklı; bunlara geçmeden önce bir
Codemagic doğrulama turu öneriliyor.

**Güncelleme (11 Eylül 2026, akşam):** Kullanıcı Codemagic üzerinden
derleneceğini onayladı ve Apple hesabına eriştim (`akokdogan59` →
`ML3UZXMU3D` takımı, Plasebo ile aynı). Yapılanlar:

- Üç App ID kaydedildi ve App Group'a bağlandı (Bölüm 1.1).
- App Store Connect'te **Selfwake** uygulaması oluşturuldu (Apple ID
  `6811170233`).
- `Selfwake/project.yml` — XcodeGen spesifikasyonu, üç hedef
  (uygulama + widget extension + watchOS companion), `SelfwakeCore`'a
  yerel paket bağımlılığı.
- Üç `.entitlements` dosyası (App Group hepsinde, HealthKit yalnız ana
  uygulamada).
- İlk buildable View katmanı: `TodayView`, `RitualFlowView` +
  `VisualizeBreathView` (Gece Ritüeli'nin dört adımı,
  `RitualCoordinator`'ı sarıyor), `ReactionTestFlowView` (Sabah PVT-lite,
  `ReactionTestSession`'ı sarıyor). Widget ve Watch hedefleri şimdilik
  yer tutucu (`SelfwakeWidgetBundle`, minimal `SelfwakeWatchApp`) —
  derlemenin uçtan uca geçmesi için var, gerçek içerikleri kendi
  alt sistem sıraları geldiğinde yazılacak.
- `Selfwake/codemagic.yaml` — Plasebo'nunkiyle aynı desen
  (`app_store_connect` entegrasyonu, TestFlight derleme numarası
  otomasyonu), tek fark `expo prebuild` yerine `xcodegen generate`.

**Kalan (kullanıcı tarafında):** Codemagic panelinde
`selfwake-distribution` sertifikası ve üç provisioning profili
(`selfwake-appstore`, `selfwake-widget-appstore`,
`selfwake-watchapp-appstore`) oluşturulmalı — bunlar Apple hesabına
bağlı işlemler, tarayıcıdan yapılabilir ama Codemagic panelinin kendi
"Generate certificate" / "Fetch profiles" akışını gerektiriyor. Ardından
ilk `ios-testflight` derlemesi tetiklenip gerçek sonuç görülecek.

**Güncelleme (11 Eylül 2026, gece):** Kullanıcı derlemeden önce tarayıcıda
bir arayüz önizlemesi istedi (Codemagic henüz tetiklenmedi); Gece Ritüeli
ve Sabah akışının gerçek Swift metinlerini/zamanlamalarını yansıtan
statik bir HTML taslağı ayrı bir Artifact olarak yayınlandı (bu depoda
değil — yalnızca inceleme için). Ardından **Onboarding ve Hatırlatıcı**
alt sistemleri tam olarak kodlandı:

- `OnboardingCoordinator` (SelfwakeCore, geri gidilebilir 7 adım) +
  yedi View (`WelcomeStep`'te vaat birebir metin).
- `RitualReminderCalculator` + `NotificationScheduling` protokolü +
  gerçek `UNRitualReminderScheduler` uygulaması (Bölüm 4.8) —
  `AlarmScheduling` ile aynı izolasyon deseni.
- `UserSettings`'e `reminderEnabled`/`reminderTime` eklendi.
- `RootView` yazıldı: ilk açılışta `UserSettings` yoksa oluşturuyor,
  `onboardingCompleted`'a göre Onboarding ya da Bugün'ü gösteriyor.

Hâlâ hiçbir test bu makinede çalıştırılmadı; hâlâ ilk gerçek doğrulama
Codemagic'i bekliyor.

Bu belge **tek bir mimari onayı** için yazıldı; gerçek implementasyon
planı burada değil. `writing-plans` becerisinin "Scope Check" kuralı
gereği, aşağıdaki alt sistemler **ayrı ayrı** bite-sized TDD planlarına
bölünecek (her biri kendi başına derlenip test edilebilir bir teslim
üretmeli):

1. **Temel** — Persistence + Models + StreakCalculator (UI'sız, saf mantık)
2. **AlarmEngine** — AlarmKit spike + Scheduler + PermissionManager
3. **Gece Ritüeli** — RitualCoordinator + 4 ekran + fade-out + opsiyonel nefes sesi
4. **Sabah akışı** — ReactionTest + MorningSummary
5. **Kör test**
6. **İlerleme + Swift Charts**
7. **Widgets + Live Activity** (App Group paylaşımı, ActivityKit, Bölüm 4.5)
8. **Intelligence katmanı** (Foundation Models + fallback + Bölüm 8'deki 7 üreticinin tamamı)
9. **HealthKit okuma**
10. **Takvim (EventKit)** — Bölüm 4.7
11. **Siri kısayolları (App Intents)** — Bölüm 4.6
12. **Watch companion** — watchOS hedefi, Bölüm 2 madde 4'teki spike'a bağlı
13. **Abonelik/StoreKit 2 + Paywall**
14. **Onboarding + Ayarlar + Tema sistemi + Yerelleştirme**

Her biri onaylandığında `superpowers:writing-plans` ile bu spec'i referans
alan ayrı bir plan dosyası yazılacak (`docs/superpowers/plans/...`), sonra
`subagent-driven-development` ile uygulanacak.

---

## 10. Ek özellik önerileri — karara bağlandı

Önceki taslaktaki yedi öneriden beşi (Watch companion, Live Activity,
Siri kısayolları, takvim okuma, opsiyonel nefes sesi) ve AI katmanındaki
üç öneri (adaptif hedef saat, akşamdan risk uyarısı, ton öğrenimi)
onaylandı ve yukarıdaki bölümlere (4.1-4.7, 8, 9) işlendi.

Kalan iki öneri — **çoklu profil** ve **topluluk karşılaştırması** —
**eklenmeyecek** (11 Eylül 2026 kararı). Topluluk karşılaştırması zaten
"sunucu yok, hesap yok" ilkesiyle çelişiyordu; çoklu profil ilkeyle
çelişmiyor ama veri modelini erkenden karmaşıklaştırdığı için kapsam
dışında tutuldu. Mimari bu haliyle **onaylandı**, Bölüm 9'daki 14 alt
sistem sıradaki iş.
