import SwiftUI
import WatchKit
import SelfwakeCore

@main
struct SelfwakeWatchApp: App {
    let modelContainer = SwiftDataContainer.make()

    init() {
        WatchAlarmRelay.shared.onVibrationCommand = {
            WKInterfaceDevice.current().play(.notification)
        }
        WatchAlarmRelay.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchTodayView()
        }
        .modelContainer(modelContainer)
    }
}
