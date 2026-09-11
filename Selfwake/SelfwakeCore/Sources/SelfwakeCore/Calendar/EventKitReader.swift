import Foundation
import EventKit

/// Bölüm 4.7: yalnızca okuma. Ertesi günün ilk etkinliği Adım 3'e
/// **öneri** olarak sunulur, alan asla otomatik doldurulup kilitlenmez.
public struct EventKitReader {
    private let store = EKEventStore()

    public init() {}

    public func requestAccess() async -> Bool {
        (try? await store.requestFullAccessToEvents()) ?? false
    }

    /// `date`'ten sonraki `interval` saniye içindeki ilk etkinliğin başlığı.
    public func firstEvent(after date: Date, within interval: TimeInterval = 16 * 3600) -> String? {
        let end = date.addingTimeInterval(interval)
        let predicate = store.predicateForEvents(withStart: date, end: end, calendars: nil)
        return store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .first?.title
    }
}

public enum NextDayFirstEventResolver {
    public static func suggestion(from reader: EventKitReader, targetWakeTime: Date) -> String? {
        reader.firstEvent(after: targetWakeTime)
    }
}
