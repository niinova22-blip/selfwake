import SwiftUI

/// Adım 2: uyanınca gözünü açtığın anı 5 saniye canlandır. "Hareketi
/// Azalt" açıksa animasyon kaybolur ama içerik kaybolmaz — statik bir
/// nefes ekranı olarak kalır (spec Bölüm 4.1).
struct VisualizeBreathView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onFinished: () -> Void
    @State private var scale: CGFloat = 0.6

    var body: some View {
        Circle()
            .fill(.white.opacity(0.15))
            .frame(width: 160, height: 160)
            .scaleEffect(reduceMotion ? 1 : scale)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 5)) { scale = 1.3 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    onFinished()
                }
            }
    }
}
