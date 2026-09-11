import Foundation
import HealthKit

/// Yalnızca okuma, yalnızca kullanıcı `UserSettings.healthKitEnabled`'ı
/// açarsa çağrılır. Hiçbir şey yazılmaz.
public struct HealthKitReader {
    private let store = HKHealthStore()

    public init() {}

    public static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    public func requestAuthorization() async -> Bool {
        guard Self.isAvailable,
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: [sleepType, heartRateType])
            return true
        } catch {
            return false
        }
    }

    /// Son 12 saatteki uyku örneklerinin toplam süresi (saniye).
    public func lastNightSleepDuration() async -> TimeInterval? {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let start = Date().addingTimeInterval(-12 * 3600)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType, predicate: predicate,
                limit: HKObjectQueryNoLimit, sortDescriptors: nil
            ) { _, samples, _ in
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                ]
                let total: TimeInterval? = (samples as? [HKCategorySample])
                    .map { samples in
                        samples
                            .filter { asleepValues.contains($0.value) }
                            .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                    }
                continuation.resume(returning: total)
            }
            store.execute(query)
        }
    }
}
