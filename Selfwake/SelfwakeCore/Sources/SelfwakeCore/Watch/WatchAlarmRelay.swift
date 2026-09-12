import Foundation
import WatchConnectivity

/// Spec Bölüm 2 madde 4'teki yedek yol: AlarmKit'in watchOS karşılığı
/// Codemagic'te doğrulanana kadar, telefon alarmı çaldığında Watch'a
/// yalnızca bir titreşim komutu gönderiliyor. İki tarafta da (telefon
/// gönderir, Watch alır) aynı sınıf kullanılıyor — `WCSession` her iki
/// platformda da var, yalnızca birkaç delegate metodu iOS'a özel.
public final class WatchAlarmRelay: NSObject, WCSessionDelegate, @unchecked Sendable {
    public static let shared = WatchAlarmRelay()
    public var onVibrationCommand: (() -> Void)?

    public func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Telefon tarafında: alarm çaldığında çağrılır.
    public func sendVibrationCommand() {
        guard WCSession.default.activationState == .activated, WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["command": "vibrate"], replyHandler: nil, errorHandler: nil)
    }

    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard message["command"] as? String == "vibrate" else { return }
        onVibrationCommand?()
    }

    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}
