import SwiftUI
import SelfwakeCore

/// `ThemeID`'nin (SelfwakeCore) rengine dökülmüş hâli. Ritüel ekranları
/// (`NightRitual/*`) bunu **okumaz** — sabit koyu paleti kullanırlar
/// (spec Bölüm 4.1).
struct Theme {
    let id: ThemeID
    let background: LinearGradient
    let accent: Color
    let text: Color
    let textMuted: Color

    static func resolve(_ id: ThemeID) -> Theme {
        switch id {
        case .nightBlue:
            return Theme(
                id: id,
                background: LinearGradient(colors: [Color(hex: 0x0B1224), Color(hex: 0x131B2E)], startPoint: .top, endPoint: .bottom),
                accent: Color(hex: 0x6E9BFF),
                text: Color(hex: 0xEAEEF7),
                textMuted: Color(hex: 0x8C99B3)
            )
        case .charcoal:
            return Theme(
                id: id,
                background: LinearGradient(colors: [Color(hex: 0x000000), Color(hex: 0x0A0A0A)], startPoint: .top, endPoint: .bottom),
                accent: Color(hex: 0xE0A458),
                text: Color(hex: 0xF2F2F2),
                textMuted: Color(hex: 0x8A8A8A)
            )
        case .dawn:
            return Theme(
                id: id,
                background: LinearGradient(colors: [Color(hex: 0x2B1B3D), Color(hex: 0x5A2A1E)], startPoint: .top, endPoint: .bottom),
                accent: Color(hex: 0xFF9E6E),
                text: Color(hex: 0xF7EEEA),
                textMuted: Color(hex: 0xC9AFA3)
            )
        case .forest:
            return Theme(
                id: id,
                background: LinearGradient(colors: [Color(hex: 0x0E1F1A), Color(hex: 0x123028)], startPoint: .top, endPoint: .bottom),
                accent: Color(hex: 0x4FD1A5),
                text: Color(hex: 0xEAF7F1),
                textMuted: Color(hex: 0x8FB3A6)
            )
        case .daylight:
            return Theme(
                id: id,
                background: LinearGradient(colors: [Color(hex: 0xFAF9F6), Color(hex: 0xF1EFE9)], startPoint: .top, endPoint: .bottom),
                accent: Color(hex: 0x3A5CE0),
                text: Color(hex: 0x1C1B18),
                textMuted: Color(hex: 0x6B6558)
            )
        }
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.resolve(.nightBlue)
}

extension EnvironmentValues {
    var selfwakeTheme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
