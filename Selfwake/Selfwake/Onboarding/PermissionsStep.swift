import SwiftUI
import SelfwakeCore

struct PermissionsStep: View {
    @State private var alarmState: AlarmPermissionState = .notDetermined
    @State private var notificationsGranted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("İzinler")
                .font(.title2.bold())

            PermissionRow(
                title: "Alarm",
                detail: "Güvenlik ağının sessiz modu delip çalabilmesi için zorunlu.",
                status: alarmStatusText
            ) {
                Task { alarmState = await AlarmPermissionManager.requestAuthorization() }
            }

            PermissionRow(
                title: "Bildirim",
                detail: "Gece ritüeli hatırlatıcısı için.",
                status: notificationsGranted ? "Verildi" : "İste"
            ) {
                Task { notificationsGranted = await UNRitualReminderScheduler().requestAuthorization() }
            }

            PermissionRow(
                title: "Sağlık (opsiyonel)",
                detail: "Uyku ve nabız verisi, yalnızca istersen.",
                status: "Ayarlar'dan"
            ) {}

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var alarmStatusText: String {
        switch alarmState {
        case .notDetermined: return "İste"
        case .authorized: return "Verildi"
        case .denied: return "Reddedildi"
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let detail: String
    let status: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Button(status, action: action)
                .buttonStyle(.bordered)
                .tint(.white)
        }
    }
}
