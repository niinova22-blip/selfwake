import AppIntents

/// "Hey Siri, gece ritüelimi başlat." `RootView`/`TodayView` şu an
/// merkezi bir yönlendirici (AppRouter) kullanmıyor — bu yüzden intent
/// yalnızca uygulamayı ön plana çıkarıyor; ritüeli otomatik açmak için
/// gelecekte paylaşılan bir navigasyon durumu gerekecek (spec Bölüm 9,
/// "Onboarding + Ayarlar" sonrası bir iyileştirme olarak not düşüldü).
struct StartRitualIntent: AppIntent {
    static var title: LocalizedStringResource = "Gece ritüelini başlat"
    static var description = IntentDescription("Selfwake'te gece ritüelini başlatır.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct OpenTodayIntent: AppIntent {
    static var title: LocalizedStringResource = "Selfwake'i aç"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}

struct SelfwakeShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartRitualIntent(),
            phrases: ["\(.applicationName) ritüelimi başlat"],
            shortTitle: "Gece Ritüeli",
            systemImageName: "moon.stars"
        )
        AppShortcut(
            intent: OpenTodayIntent(),
            phrases: ["\(.applicationName) aç"],
            shortTitle: "Selfwake'i Aç",
            systemImageName: "sun.max"
        )
    }
}
