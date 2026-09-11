import SwiftUI
import SwiftData
import SelfwakeCore

struct SettingsView: View {
    @Bindable var settings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false
    @State private var showPaywall = false
    @State private var showScience = false
    @State private var store = StoreKitManager()

    var body: some View {
        Form {
            Section("Hedef") {
                DatePicker("Varsayılan hedef saat", selection: $settings.targetTimeDefault, displayedComponents: .hourAndMinute)
            }

            Section("Görünüm") {
                Picker("Tema", selection: $settings.themeID) {
                    ForEach(ThemeID.allCases, id: \.rawValue) { id in
                        Text(id.displayName).tag(id.rawValue)
                    }
                }
                Toggle("Hareketi Azalt (uygulamaya özel)", isOn: Binding(
                    get: { settings.reduceMotionOverride ?? false },
                    set: { settings.reduceMotionOverride = $0 }
                ))
            }

            Section("Hatırlatıcı") {
                Toggle("Ritüel hatırlatıcısı", isOn: $settings.reminderEnabled)
                if settings.reminderEnabled {
                    DatePicker("Saat", selection: $settings.reminderTime, displayedComponents: .hourAndMinute)
                }
            }

            Section("Veri kaynakları") {
                Toggle("Sağlık verisi (uyku, nabız)", isOn: $settings.healthKitEnabled)
                Toggle("Takvim (ertesi günün ilk işi)", isOn: $settings.calendarEnabled)
                Toggle("Watch üzerinden titreşim", isOn: $settings.watchCompanionEnabled)
                Toggle("Kilit ekranı canlı durumu", isOn: $settings.liveActivityEnabled)
            }

            Section("Ölçüm") {
                Toggle("Kör test", isOn: $settings.blindTestEnabled)
                    .disabled(!isPlus)
                if !isPlus {
                    Button("Kör test Selfwake Plus ile açılır") { showPaywall = true }
                        .font(.footnote)
                }
            }

            Section("Abonelik") {
                Button(isPlus ? "Aboneliği yönet" : "Selfwake Plus'a geç") { showPaywall = true }
            }

            Section {
                Button("Nasıl çalışır") { showScience = true }
            }

            Section("Veri") {
                Button("Tüm veriyi kalıcı sil", role: .destructive) { showDeleteConfirm = true }
            }
        }
        .navigationTitle("Ayarlar")
        .task { await store.refreshEntitlements() }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showScience) { ScienceStep() }
        .confirmationDialog(
            "Tüm veri kalıcı olarak silinecek. Bu işlem geri alınamaz.",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive, action: deleteAllData)
            Button("Vazgeç", role: .cancel) {}
        }
    }

    private var isPlus: Bool { store.tier == .plus }

    private func deleteAllData() {
        try? modelContext.delete(model: Night.self)
        try? modelContext.delete(model: ReactionTest.self)
        try? modelContext.delete(model: UserSettings.self)
        try? modelContext.save()
        // Silme sonrası bu View'ın `settings` referansı geçersiz — hemen
        // kapatılıyor. RootView, UserSettings kalmadığını @Query ile görüp
        // yeniden Onboarding'e düşecek.
        dismiss()
    }
}
