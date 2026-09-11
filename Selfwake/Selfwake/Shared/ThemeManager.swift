import SwiftUI
import SwiftData
import SelfwakeCore

/// `UserSettings.themeID`'yi okuyup `.environment(\.selfwakeTheme, ...)`
/// ile dağıtır. `RootView` bunu bir kez kurar, alt View'lar
/// `@Environment(\.selfwakeTheme)` ile okur.
@Observable
final class ThemeManager {
    var current: Theme

    init(themeID: ThemeID) {
        self.current = Theme.resolve(themeID)
    }

    func update(themeID: ThemeID) {
        current = Theme.resolve(themeID)
    }
}
