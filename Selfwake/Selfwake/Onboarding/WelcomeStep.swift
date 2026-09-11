import SwiftUI

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("“Sabahları yorgun uyanmayın.\nAlarm kurmayı bırakın —\nbeyninizde çalan sese güvenin.”")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text("Selfwake, alarmsız uyanmayı öğretir. Amacı kendini gereksiz kılmaktır.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
