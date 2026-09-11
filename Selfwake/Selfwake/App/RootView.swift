import SwiftUI
import SwiftData
import SelfwakeCore

/// Uygulama açılışında `UserSettings` var mı diye bakar; yoksa
/// güvenli varsayılanlarla bir tane oluşturur (ilk açılış). Onboarding
/// tamamlanana kadar `OnboardingFlowView`, sonrasında `TodayView` gösterilir.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]

    var body: some View {
        Group {
            if let settings = allSettings.first {
                if settings.onboardingCompleted {
                    TodayView()
                } else {
                    OnboardingFlowView(settings: settings)
                }
            } else {
                ProgressView()
                    .onAppear(perform: createDefaultSettings)
            }
        }
    }

    private func createDefaultSettings() {
        guard allSettings.isEmpty else { return }
        let defaultTarget = Calendar.current.date(
            bySettingHour: 7, minute: 0, second: 0, of: .now
        ) ?? .now
        let settings = UserSettings(targetTimeDefault: defaultTarget)
        modelContext.insert(settings)
        try? modelContext.save()
    }
}
