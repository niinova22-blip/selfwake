import SwiftUI
import SwiftData
import SelfwakeCore

/// `OnboardingCoordinator` (SelfwakeCore) sırayı taşır; bu View yalnızca
/// adıma göre ekranı seçer ve geri/devam düğmelerini çizer.
struct OnboardingFlowView: View {
    @Bindable var settings: UserSettings
    @Environment(\.modelContext) private var modelContext
    @State private var coordinator = OnboardingCoordinator()

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            controls
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.step {
        case .welcome: WelcomeStep()
        case .howItWorks: HowItWorksStep()
        case .science: ScienceStep()
        case .honesty: HonestyStep()
        case .permissions: PermissionsStep()
        case .reminderSetup: ReminderSetupStep(reminderTime: $settings.reminderTime)
        case .targetTimeSetup: TargetTimeSetupStep(targetTime: $settings.targetTimeDefault)
        }
    }

    private var controls: some View {
        HStack {
            if !coordinator.step.isFirst {
                Button("Geri") { coordinator.goBack() }
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            Button(coordinator.step.isLast ? "Selfwake'i başlat" : "Devam et") {
                if coordinator.step.isLast {
                    finishOnboarding()
                } else {
                    coordinator.advance()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }

    private func finishOnboarding() {
        settings.onboardingCompleted = true
        try? modelContext.save()

        if settings.reminderEnabled {
            let components = RitualReminderCalculator.hourMinuteComponents(from: settings.reminderTime)
            Task {
                let scheduler = UNRitualReminderScheduler()
                guard await scheduler.requestAuthorization() else { return }
                let text = settings.targetTimeDefault.formatted(date: .omitted, time: .shortened)
                await scheduler.scheduleDailyReminder(
                    hour: components.hour ?? 22,
                    minute: components.minute ?? 30,
                    targetTimeText: text
                )
            }
        }
    }
}
