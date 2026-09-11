import SwiftUI

struct HonestyStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Dürüst olalım")
                .font(.title2.bold())
            Text("Herkes bunu yapamaz. Düzenli bir uyku programı gerekiyor — her gün farklı bir saat hedeflemek uykunu bozabilir.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Text("Selfwake düzensiz hedefleri uyarır, ama seçim senin.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
