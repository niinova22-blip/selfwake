import SwiftUI
import SwiftData
import SelfwakeCore

@main
struct SelfwakeApp: App {
    let modelContainer = SwiftDataContainer.make()

    init() {
        // Bölüm 4.2: alarm gerçekten çaldığında bu sınıfın
        // `sendVibrationCommand()`'ını çağırmak gerekiyor. AlarmKit'in
        // "alarm sunuluyor" olayını dinleme API'si Codemagic'te
        // doğrulanana kadar bu bağlantı eksik — Watch companion alt
        // sisteminin geri kalan işi (spec Bölüm 9, madde 12).
        WatchAlarmRelay.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
