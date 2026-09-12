#if canImport(ActivityKit)
import Foundation
import ActivityKit

/// Bölüm 4.5: `RitualCoordinator` `.fadeOut`'a geçtiğinde başlar, sabah
/// testi bitince kapanır. Widget extension da bunu okuyacağı için
/// SelfwakeCore'da — hem app hem widget hedefi aynı tipi paylaşıyor.
/// ActivityKit watchOS'ta yok; SelfwakeWatchApp bu tipi kullanmadığı için
/// `canImport` ile watch derlemesinden tamamen çıkarılıyor.
public struct NightActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var targetTime: Date
        public init(targetTime: Date) {
            self.targetTime = targetTime
        }
    }

    public init() {}
}
#endif
