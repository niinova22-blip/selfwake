import Foundation
import SwiftData

public enum SwiftDataContainer {
    /// Ana uygulama, widget extension ve watch hedefinin `Signing & Capabilities`
    /// bölümünde birebir aynı şekilde tanımlanmış olmalı.
    public static let appGroupID = "group.com.selfwake.app"

    public static func make() -> ModelContainer {
        let schema = Schema([Night.self, ReactionTest.self, UserSettings.self])

        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appending(path: "Selfwake.sqlite")
        else {
            fatalError(
                "App Group konteyneri bulunamadı — \(appGroupID) capability'sinin " +
                "hem ana uygulamada hem widget/watch hedeflerinde açık olduğundan emin ol."
            )
        }

        let configuration = ModelConfiguration(schema: schema, url: groupURL)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData container kurulamadı: \(error)")
        }
    }
}
