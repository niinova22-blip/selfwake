import Foundation
import AlarmKit

/// AlarmKit boş metadata gerektiriyor (spec araştırmasında görülen örnek:
/// `EmptyMetadata`). `nonisolated` işareti Apple'ın kendi örneklerinde de var.
public struct SelfwakeAlarmMetadata: AlarmMetadata {
    public init() {}
}

/// Uygulamanın geri kalanının bağlandığı arayüz — gerçek AlarmKit çağrıları
/// yalnızca `AlarmKitScheduler`'da. Bu ayrım sayesinde AlarmKit'in kesin isim
/// ve imzaları (spec Bölüm 2 madde 1-2) Codemagic'te derlenirken düzeltilse
/// bile geri kalan kod (`RitualCoordinator`, `AppRouter`) etkilenmez.
public protocol AlarmScheduling {
    func schedule(id: UUID, fireDate: Date, volumeLevel: Double) async throws
    func cancel(id: UUID) async throws
}

public struct AlarmKitScheduler: AlarmScheduling {
    public init() {}

    public func schedule(id: UUID, fireDate: Date, volumeLevel: Double) async throws {
        let presentation = AlarmPresentation(
            alert: .init(
                title: "Selfwake",
                stopButton: .init(text: "Kapat", textColor: .white, systemImageName: "xmark")
            )
        )
        let attributes = AlarmAttributes<SelfwakeAlarmMetadata>(
            presentation: presentation,
            tintColor: .accentColor
        )
        let configuration = AlarmConfiguration(
            schedule: .fixed(fireDate),
            attributes: attributes
        )
        _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        // volumeLevel: AlarmKit'in ses seviyesi API'si Apple dokümantasyonuyla
        // teyit edilene kadar burada uygulanmıyor — spec Bölüm 2'ye açık risk
        // olarak not düşüldü, sistemin kendi ses ayarına düşülüyor.
    }

    public func cancel(id: UUID) async throws {
        try await AlarmManager.shared.cancel(id: id)
    }
}
