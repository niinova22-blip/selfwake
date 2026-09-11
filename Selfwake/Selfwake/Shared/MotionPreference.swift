import SwiftUI

/// `UserSettings.reduceMotionOverride`'ı sistem ayarıyla birleştirir.
/// `nil` = sistemi izle; `true`/`false` = kullanıcı Ayarlar'dan zorladı.
enum MotionPreference {
    static func resolved(override: Bool?, systemReduceMotion: Bool) -> Bool {
        override ?? systemReduceMotion
    }
}
