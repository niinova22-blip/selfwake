import WidgetKit
import SwiftUI
import SwiftData
import SelfwakeCore

@main
struct SelfwakeWidgetBundle: WidgetBundle {
    var body: some Widget {
        SelfwakeHomeWidget()
        NightLiveActivityWidget()
    }
}

struct SelfwakeHomeWidget: Widget {
    let kind = "SelfwakeHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SelfwakeTimelineProvider()) { entry in
            SelfwakeWidgetView(entry: entry)
        }
        .configurationDisplayName("Selfwake")
        .description("Bu gecenin hedef saati ve serin.")
    }
}

struct SelfwakeWidgetEntry: TimelineEntry {
    let date: Date
    let targetTime: Date
    let streak: Int
}

struct SelfwakeTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SelfwakeWidgetEntry {
        SelfwakeWidgetEntry(date: .now, targetTime: .now, streak: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SelfwakeWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SelfwakeWidgetEntry>) -> Void) {
        let entry = currentEntry()
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600))))
    }

    private func currentEntry() -> SelfwakeWidgetEntry {
        let container = SwiftDataContainer.make()
        let context = ModelContext(container)
        let settings = try? context.fetch(FetchDescriptor<UserSettings>()).first
        return SelfwakeWidgetEntry(
            date: .now,
            targetTime: settings?.targetTimeDefault ?? .now,
            streak: settings?.currentStreak ?? 0
        )
    }
}

struct SelfwakeWidgetView: View {
    let entry: SelfwakeWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(entry.streak) günlük seri")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(entry.targetTime, style: .time)
                .font(.system(size: 28, weight: .bold, design: .rounded))
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct NightLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NightActivityAttributes.self) { context in
            HStack {
                Text("Hedef")
                    .font(.caption)
                Spacer()
                Text(context.state.targetTime, style: .time)
                    .font(.headline)
            }
            .padding()
            .activityBackgroundTint(.black)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.targetTime, style: .time)
                        .font(.headline)
                }
            } compactLeading: {
                Image(systemName: "moon.stars.fill")
            } compactTrailing: {
                Text(context.state.targetTime, style: .time)
            } minimal: {
                Image(systemName: "moon.stars.fill")
            }
        }
    }
}
