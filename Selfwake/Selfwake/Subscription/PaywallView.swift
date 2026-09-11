import SwiftUI
import StoreKit
import SelfwakeCore

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreKitManager()

    private let features = [
        "Sınırsız tepki testi geçmişi",
        "Sapma grafikleri",
        "Değişken analizi",
        "Kör test",
        "Yapay zekâ yorumları",
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selfwake Plus")
                        .font(.largeTitle.bold())
                    Text("Gece ritüeli ve güvenlik ağı zaten sonsuza kadar ücretsiz. Plus yalnızca ölçümü açar.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(features, id: \.self) { feature in
                        Label(feature, systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                    }
                }

                if store.products.isEmpty {
                    Text("Abonelik ürünleri App Store Connect'te henüz oluşturulmadı.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.products) { product in
                        Button {
                            Task { await store.purchase(product) }
                        } label: {
                            HStack {
                                Text(product.displayName)
                                Spacer()
                                Text(product.displayPrice)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Text("Bir hafta ücretsiz deneme, sonra abonelik otomatik yenilenir.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
        }
        .task {
            await store.loadProducts()
            await store.refreshEntitlements()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Kapat") { dismiss() }
            }
        }
    }
}

#Preview {
    PaywallView()
}
