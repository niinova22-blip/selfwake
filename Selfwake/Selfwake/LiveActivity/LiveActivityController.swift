import Foundation
import ActivityKit
import SelfwakeCore

/// Bölüm 4.5. Ritüel `.fadeOut`'a geçtiğinde `start`, sabah özeti
/// göründüğünde ya da alarm çaldığında `endAll` çağrılır — hiçbir gece
/// yarısından sonra ekranda asılı kalmaz.
enum LiveActivityController {
    static func start(targetTime: Date) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = NightActivityAttributes()
        let state = NightActivityAttributes.ContentState(targetTime: targetTime)
        _ = try? Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: nil)
        )
    }

    static func endAll() {
        Task {
            for activity in Activity<NightActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
