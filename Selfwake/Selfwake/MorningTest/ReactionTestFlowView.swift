import SwiftUI
import SelfwakeCore

/// Spec Bölüm 5, "Sabah": 30 sn PVT-lite. `ReactionTestSession`
/// (SelfwakeCore) zamanlama ve kayıt mantığını taşır; bu View yalnızca
/// ekran rengini değiştirip dokunuşu iletir.
struct ReactionTestFlowView: View {
    let onFinished: (ReactionTest) -> Void

    @State private var session = ReactionTestSession()
    @State private var isStimulusVisible = false
    @State private var finished = false

    var body: some View {
        ZStack {
            (isStimulusVisible ? Color.green : Color.gray.opacity(0.3))
                .ignoresSafeArea()
                .onTapGesture {
                    guard isStimulusVisible else { return }
                    session.recordTap(at: .now)
                    isStimulusVisible = false
                    scheduleNextStimulus()
                }

            if finished {
                VStack(spacing: 16) {
                    Text("Bitti — ortalama \(Int(session.makeReactionTest(testDate: .now).averageMs)) ms")
                        .foregroundStyle(.white)
                    Button("Devam et") { onFinished(session.makeReactionTest(testDate: .now)) }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .onAppear {
            session.start(at: .now)
            scheduleNextStimulus()
        }
        .onChange(of: finished) { _, isFinished in
            if isFinished { LiveActivityController.endAll() }
        }
    }

    private func scheduleNextStimulus() {
        guard !session.isFinished(at: .now) else {
            finished = true
            return
        }
        let delay = Double.random(in: 1...3)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !session.isFinished(at: .now) else {
                finished = true
                return
            }
            session.stimulusAppeared(at: .now)
            isStimulusVisible = true
        }
    }
}

#Preview {
    ReactionTestFlowView(onFinished: { _ in })
}
