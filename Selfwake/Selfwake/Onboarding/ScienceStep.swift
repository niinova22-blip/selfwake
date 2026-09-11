import SwiftUI

struct ScienceStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Bilimsel temel")
                .font(.title2.bold())
            Text("Uykunun belirli bir saatte biteceği beklentisi, uyanmadan bir saat önce ACTH hormonunun yükselmesine yol açıyor. Bu hazırlık uyku ataletini azaltıyor; kendiliğinden uyananlar tepki süresi testlerinde daha iyi performans gösteriyor.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            VStack(alignment: .leading, spacing: 6) {
                Text("Born ve ark., Nature (1999)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
                Text("Ikeda & Hayashi (2014)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text("Yetişkinlerin yarısına yakını bunu yapabiliyor, %15 kadarı alışkanlık hâline getirmiş.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
