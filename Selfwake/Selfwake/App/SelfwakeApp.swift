import SwiftUI
import SwiftData
import SelfwakeCore

@main
struct SelfwakeApp: App {
    let modelContainer = SwiftDataContainer.make()

    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(modelContainer)
    }
}
