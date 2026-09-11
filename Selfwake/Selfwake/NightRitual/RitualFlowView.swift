import SwiftUI
import SelfwakeCore

/// Spec Bölüm 4.1: tek ekranda tek şey, liste yok, açıklama paragrafı
/// yok. `RitualCoordinator` (SelfwakeCore) tüm ilerleme mantığını taşır;
/// bu View yalnızca `state`'i okur ve `advance()`/`setFirstActionWord`
/// çağırır.
struct RitualFlowView: View {
    @State private var coordinator: RitualCoordinator
    @State private var firstActionInput = ""

    init(targetTime: Date) {
        _coordinator = State(initialValue: RitualCoordinator(targetTime: targetTime))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch coordinator.state {
            case .confirmTime:
                confirmTimeStep
            case .step1SayTime:
                sayTimeStep
            case .step2Visualize:
                visualizeStep
            case .step3FirstAction:
                firstActionStep
            case .fadeOut:
                // Bölüm 4.3: sözü olmayan bir bitiş — buton, metin, iddia yok.
                Color.black.ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(coordinator.state == .fadeOut)
    }

    private var confirmTimeStep: some View {
        VStack(spacing: 32) {
            Text(coordinator.targetTime, style: .time)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Button("Başla") { coordinator.advance() }
                .buttonStyle(.borderedProminent)
        }
    }

    private var sayTimeStep: some View {
        VStack(spacing: 24) {
            Text(coordinator.targetTime, style: .time)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Yüksek sesle söyle, sonra dokun")
                .foregroundStyle(.white.opacity(0.6))
        }
        .contentShape(Rectangle())
        .onTapGesture { coordinator.advance() }
    }

    private var visualizeStep: some View {
        VisualizeBreathView(onFinished: { coordinator.advance() })
    }

    private var firstActionStep: some View {
        VStack(spacing: 24) {
            Text("Uyanınca ilk yapacağın şey?")
                .foregroundStyle(.white)
            TextField("tek kelime", text: $firstActionInput)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 200)
                .onSubmit {
                    coordinator.setFirstActionWord(firstActionInput)
                    coordinator.advance()
                }
        }
        .padding()
    }
}

#Preview {
    RitualFlowView(targetTime: .now)
}
