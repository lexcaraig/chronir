import Foundation
import Observation
import StoreKit

@Observable
final class SubscriptionService {
    static let shared = SubscriptionService()

    private(set) var products: [Product] = []
    private(set) var currentTier: SubscriptionTier = .free {
        didSet {
            UserDefaults.standard.set(currentTier.rawValue, forKey: "chronir_last_known_tier")
        }
    }
    private(set) var activeProductID: String?
    private(set) var renewalDate: Date?
    var isLoading = false
    var errorMessage: String?
    private(set) var statusChecked = false

    private var transactionListenerTask: Task<Void, Never>?

    private static var persistedTier: SubscriptionTier {
        let raw = UserDefaults.standard.string(forKey: "chronir_last_known_tier") ?? "free"
        return SubscriptionTier(rawValue: raw) ?? .free
    }

    // TODO: Add premium product IDs when Premium tier is built (Phase 4, Sprint 11+)
    static let productIDs: Set<String> = [
        "com.chronir.plus.annual",
        "com.chronir.plus.monthly"
    ]

    private init() {}

    // MARK: - Product Loading

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price > $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    // MARK: - Purchase

    @discardableResult
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus()
            await transaction.finish()
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    // MARK: - Transaction Listener

    func listenForTransactions() {
        transactionListenerTask?.cancel()
        transactionListenerTask = Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Subscription Status

    func updateSubscriptionStatus() async {
        var highestTier: SubscriptionTier = .free
        var latestProductID: String?
        var latestRenewalDate: Date?

        for await result in StoreKit.Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            guard transaction.revocationDate == nil else { continue }

            let tier = Self.tierForProductID(transaction.productID)
            if tier.rank > highestTier.rank {
                highestTier = tier
                latestProductID = transaction.productID
                latestRenewalDate = transaction.expirationDate
            }
        }

        let previousTier = Self.persistedTier
        currentTier = highestTier
        activeProductID = latestProductID
        renewalDate = latestRenewalDate

        statusChecked = true
    }

    // MARK: - Restore

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    static func tierForProductID(_ productID: String) -> SubscriptionTier {
        if productID.contains("premium") {
            return .premium
        } else if productID.contains("plus") {
            return .plus
        }
        return .free
    }

    // MARK: - Product Accessors

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    var plusMonthly: Product? { product(for: "com.chronir.plus.monthly") }
    var plusAnnual: Product? { product(for: "com.chronir.plus.annual") }
    // TODO: Add premium product accessors when Premium tier is built (Phase 4, Sprint 11+)
}

// MARK: - Tier Rank

extension SubscriptionTier {
    var rank: Int {
        switch self {
        case .free: return 0
        case .plus: return 1
        case .premium: return 2
        case .family: return 3
        }
    }
}

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        }
    }
}
