import WidgetKit
import SwiftUI

@main
struct SelfwakeWidgetBundle: WidgetBundle {
    var body: some Widget {
        SelfwakeHomeWidget()
    }
}

struct SelfwakeHomeWidget: Widget {
    let kind = "SelfwakeHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SelfwakeTimelineProvider()) { entry in
            Text(entry.date, style: .time)
        }
        .configurationDisplayName("Selfwake")
        .description("Bu gecenin hedef saati.")
    }
}

struct SelfwakeTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SelfwakeWidgetEntry {
        SelfwakeWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (SelfwakeWidgetEntry) -> Void) {
        completion(SelfwakeWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SelfwakeWidgetEntry>) -> Void) {
        completion(Timeline(entries: [SelfwakeWidgetEntry(date: .now)], policy: .atEnd))
    }
}

struct SelfwakeWidgetEntry: TimelineEntry {
    let date: Date
}
