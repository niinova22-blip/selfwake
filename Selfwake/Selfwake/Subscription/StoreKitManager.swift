import Foundation
import StoreKit
import SelfwakeCore

/// StoreKit 2 üzerinden Plasebo Plus... hayır, **Selfwake Plus**
/// aboneliğini yönetir. Sunucu yok — `Transaction.currentEntitlements`
/// yerel doğrulama için yeterli.
///
/// **Not:** Bu ürün kimlikleri App Store Connect'te henüz oluşturulmadı
/// (spec Bölüm 1.1'deki "Yapılmayanlar" listesi). Ürünler kurulana kadar
/// `Product.products(for:)` boş dizi döner, `tier` hep `.free` kalır —
/// uygulama çökmez, yalnızca satın alma ekranı boş görünür.
@MainActor
@Observable
final class StoreKitManager {
    static let monthlyID = "com.selfwake.app.plus.monthly"
    static let yearlyID = "com.selfwake.app.plus.yearly"

    private(set) var tier: SubscriptionTier = .free
    private(set) var products: [Product] = []
    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        products = (try? await Product.products(for: [Self.monthlyID, Self.yearlyID])) ?? []
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            await handle(result)
        }
    }

    func purchase(_ product: Product) async {
        guard let result = try? await product.purchase() else { return }
        if case .success(let verification) = result {
            await handle(verification)
        }
    }

    private func handle(_ verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else { return }
        if transaction.revocationDate == nil {
            tier = .plus
        }
        await transaction.finish()
    }
}
