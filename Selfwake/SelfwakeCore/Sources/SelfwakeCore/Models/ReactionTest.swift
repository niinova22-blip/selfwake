import Foundation
import SwiftData

@Model
public final class ReactionTest {
    public var id: UUID
    public var night: Night?
    public var timestampsMs: [Double]
    public var testDate: Date

    public init(
        id: UUID = UUID(),
        night: Night? = nil,
        timestampsMs: [Double] = [],
        testDate: Date
    ) {
        self.id = id
        self.night = night
        self.timestampsMs = timestampsMs
        self.testDate = testDate
    }

    public var averageMs: Double {
        timestampsMs.isEmpty ? 0 : timestampsMs.reduce(0, +) / Double(timestampsMs.count)
    }
}
