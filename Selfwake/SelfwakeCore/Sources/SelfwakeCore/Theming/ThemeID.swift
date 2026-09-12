import Foundation

/// Spec Bölüm 6 — bes tema. Renklerin kendisi (Color) app hedefindeki
/// `Theme.swift`'te; burada yalnızca kimlik ve görüntü adı, test
/// edilebilir kalsın diye.
public enum ThemeID: String, CaseIterable, Codable, Sendable {
    case nightBlue, charcoal, dawn, forest, daylight

    public var displayName: String {
        switch self {
        case .nightBlue: return "Gece Mavisi"
        case .charcoal: return "Kömür"
        case .dawn: return "Şafak"
        case .forest: return "Orman"
        case .daylight: return "Öğlen"
        }
    }

    /// Yalnızca `daylight` açık tema; geri kalan dört tema koyu.
    public var isDark: Bool { self != .daylight }
}
