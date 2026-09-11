import Testing
@testable import SelfwakeCore

@Suite("ThemeID")
struct ThemeIDTests {
    @Test("Beş tema var")
    func fiveThemes() {
        #expect(ThemeID.allCases.count == 5)
    }

    @Test("Yalnızca daylight açık tema")
    func onlyDaylightIsLight() {
        for theme in ThemeID.allCases {
            #expect(theme.isDark == (theme != .daylight))
        }
    }

    @Test("Ham değerden themeID string'e geri dönüşür (UserSettings.themeID uyumu)")
    func roundTripsFromRawValue() {
        #expect(ThemeID(rawValue: "nightBlue") == .nightBlue)
    }
}
