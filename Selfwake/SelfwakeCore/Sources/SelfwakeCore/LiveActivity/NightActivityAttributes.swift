import Foundation
import ActivityKit

/// Bölüm 4.5: `RitualCoordinator` `.fadeOut`'a geçtiğinde başlar, sabah
/// testi bitince kapanır. Widget extension da bunu okuyacağı için
/// SelfwakeCore'da — hem app hem widget hedefi aynı tipi paylaşıyor.
public struct NightActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var targetTime: Date
        public init(targetTime: Date) {
            self.targetTime = targetTime
        }
    }

    public init() {}
}
