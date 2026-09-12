import SwiftUI
import SwiftData
import SelfwakeCore

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [UserSettings]
    @Query(sort: \Night.date, order: .reverse) private var nights: [Night]
    @Query(sort: \ReactionTest.testDate, order: .reverse) private var reactionTests: [ReactionTest]

    @State private var showRitual = false
    @State private var showBlindWaiting = false
    @State private var showMorningTest = false
    @State private var pendingNight: Night?
    @State private var lastCompletedNight: Night?
    @State private var lastReactionTest: ReactionTest?

    private var settings: UserSettings? { allSettings.first }
    private var targetTime: Date { settings?.targetTimeDefault ?? .now }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("\(settings?.currentStreak ?? 0) günlük seri")
                    .font(.caption)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())

                Text("Bu geceki hedef")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(targetTime, style: .time)
                    .font(.system(size: 56, weight: .bold, design: .rounded))

                if let warning = eveningWarning {
                    Text(warning)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button("Gece Ritüelini Başlat") { startNight() }
                    .buttonStyle(.borderedProminent)

                Button("Sabah tepki testini şimdi başlat") { showMorningTest = true }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink("İlerleme") { StatsView() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let settings {
                        NavigationLink { SettingsView(settings: settings) } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRitual) {
            RitualFlowView(targetTime: targetTime, onComplete: handleRitualComplete)
        }
        .fullScreenCover(isPresented: $showBlindWaiting) {
            BlindWaitingView(duration: 30) { finishBlindNight() }
        }
        .fullScreenCover(isPresented: $showMorningTest) {
            NavigationStack {
                ReactionTestFlowView(onFinished: handleReactionTestComplete)
            }
        }
        .sheet(item: $lastCompletedNight) { night in
            if let test = lastReactionTest {
                MorningSummaryView(
                    night: night,
                    todayReaction: test,
                    yesterdayReaction: reactionTests.dropFirst().first,
                    onDone: { lastCompletedNight = nil }
                )
            }
        }
    }

    private var eveningWarning: String? {
        // Yatış saati henüz ayrı kaydedilmiyor (Bölüm 3'te `bedTime` var ama
        // giriş noktası yok); şimdilik hep nil dönüyor — HealthKit ya da
        // elle giriş eklendiğinde EveningRiskWarningGenerator gerçek veriyle beslenecek.
        EveningRiskWarningGenerator.warning(bedTimeDeltaMinutes: nil)
    }

    private func startNight() {
        guard let settings else { showRitual = true; return }
        let roll = BlindTestScheduler.assign(
            blindTestEnabled: settings.blindTestEnabled,
            inclusionRoll: .random(in: 0..<1),
            decoyRoll: .random(in: 0..<1)
        )
        if roll.isBlindDecoy {
            pendingNight = Night(date: .now, targetTime: targetTime, isBlindTest: true, isBlindDecoy: true)
            showBlindWaiting = true
        } else {
            showRitual = true
        }
    }

    private func finishBlindNight() {
        showBlindWaiting = false
        if let night = pendingNight {
            modelContext.insert(night)
            try? modelContext.save()
            scheduleAlarm(for: night)
        }
        pendingNight = nil
    }

    private func handleRitualComplete(_ night: Night) {
        modelContext.insert(night)
        try? modelContext.save()
        scheduleAlarm(for: night)
        showRitual = false
    }

    private func scheduleAlarm(for night: Night) {
        guard let settings else { return }
        let tier = StreakTier(rawValue: min(max(settings.alarmOffsetMinutes / 3, 0), 4)) ?? .tier0
        let fireDate = AlarmSchedulingDecision.scheduledFireDate(
            targetTime: night.targetTime, offsetMinutes: tier.alarmOffsetMinutes
        )
        Task {
            try? await AlarmSchedulerFactory.make().schedule(id: UUID(), fireDate: fireDate, volumeLevel: tier.alarmVolumeLevel)
        }
    }

    private func handleReactionTestComplete(_ test: ReactionTest) {
        modelContext.insert(test)
        try? modelContext.save()
        lastReactionTest = test
        lastCompletedNight = nights.first
        showMorningTest = false
    }
}

#Preview {
    TodayView()
}
