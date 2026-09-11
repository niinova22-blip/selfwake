import SwiftUI

/// Spec Bölüm 5: niyet protokolü yerine, aynı toplam süre ve aynı geçiş
/// hızıyla boş bir bekleme ekranı. Hangi gecenin sahte olduğu sabaha
/// kadar hiçbir yerde gösterilmez — bu View de dahil.
struct BlindWaitingView: View {
    let duration: TimeInterval
    let onFinished: () -> Void
    @State private var opacity: Double = 0.3

    var body: some View {
        Color.black
            .ignoresSafeArea()
            .overlay(
                Circle()
                    .fill(.white.opacity(opacity))
                    .frame(width: 4, height: 4)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: duration / 2).repeatForever(autoreverses: true)) {
                    opacity = 0.05
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    onFinished()
                }
            }
            .preferredColorScheme(.dark)
    }
}
