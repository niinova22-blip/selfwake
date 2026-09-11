import SwiftUI

struct HowItWorksStep: View {
    private let items = [
        ("Gece", "Hedef saati seç, kısa bir niyet ritüeli yap."),
        ("Güvenlik ağı", "Hedeften önce uyanırsan hiç çalmaz."),
        ("Sabah", "30 saniyelik tepki testiyle uyanıklığını ölç."),
        ("Zamanla", "Başarı arttıkça güvenlik ağı geriye çekilir, sesi kısılır."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Nasıl çalışır")
                .font(.title2.bold())
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.system(.body, design: .rounded).bold())
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(.white.opacity(0.12)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0).font(.headline)
                        Text(item.1)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
