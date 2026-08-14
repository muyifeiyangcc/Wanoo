import Foundation
import StoreKit

final class InAppPurchaseManager: NSObject {
    static let shared = InAppPurchaseManager()

    enum State { case idle, loading, purchasing, completed(SKProduct), cancelled, failed }
    static let stateChanged = Notification.Name("WanooPurchaseStateChanged")

    struct ProductPlan: Equatable {
        let productID: String
        let coins: Int
        let usdPrice: String
    }

    private let testPlans: [ProductPlan] = [
        ProductPlan(productID: "nqduuzkjsmzkaplv", coins: 400, usdPrice: "$0.99"),
        ProductPlan(productID: "ocaxfmcmghhyzxnz", coins: 800, usdPrice: "$1.99"),
        ProductPlan(productID: "ftxrirldrkltwphy", coins: 2_450, usdPrice: "$4.99"),
        ProductPlan(productID: "dosfjfyfilpvialo", coins: 5_150, usdPrice: "$9.99"),
        ProductPlan(productID: "lbiizwixmornamqd", coins: 6_400, usdPrice: "$12.99"),
        ProductPlan(productID: "awqdpmsulhawatiy", coins: 10_800, usdPrice: "$19.99"),
        ProductPlan(productID: "rdalalhkifvtmbdh", coins: 14_900, usdPrice: "$24.99"),
        ProductPlan(productID: "fhdqqatmdibiambe", coins: 29_400, usdPrice: "$49.99"),
        ProductPlan(productID: "rqjmznkyorxxppxx", coins: 39_500, usdPrice: "$79.99"),
        ProductPlan(productID: "voaesvpxyqttdyjz", coins: 63_700, usdPrice: "$99.99")
    ]

    /// Formal builds provide up to ten entries in Info.plist under
    /// WanooProductionProducts: [{ productID, coins, usdPrice }].
    private var productionPlans: [ProductPlan] {
        guard let values = Bundle.main.object(forInfoDictionaryKey: "WanooProductionProducts") as? [[String: Any]] else { return [] }
        return values.prefix(10).compactMap { value in
            guard let id = value["productID"] as? String,
                  let coins = value["coins"] as? Int,
                  let price = value["usdPrice"] as? String,
                  !id.isEmpty, coins > 0, price.hasPrefix("$") else { return nil }
            return ProductPlan(productID: id, coins: coins, usdPrice: price)
        }
    }

    private var activePlans: [ProductPlan] {
        Bundle.main.bundleIdentifier == "app.myfy.test" ? testPlans : productionPlans
    }

    var testProductIDs: Set<String> { Set(testPlans.map(\.productID)) }
    var productionProductIDs: Set<String> { Set(productionPlans.map(\.productID)) }
    private(set) var products: [SKProduct] = []
    private(set) var state: State = .idle { didSet { NotificationCenter.default.post(name: Self.stateChanged, object: self) } }
    private var request: SKProductsRequest?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit { SKPaymentQueue.default().remove(self) }

    func loadProducts() {
        state = .loading
        request?.cancel()
        let ids = Set(activePlans.map(\.productID))
        guard !ids.isEmpty else { state = .failed; return }
        let request = SKProductsRequest(productIdentifiers: ids)
        self.request = request
        request.delegate = self
        request.start()
    }

    func purchase(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { state = .failed; return }
        state = .purchasing
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    func dollarPrice(for product: SKProduct) -> String {
        plan(for: product.productIdentifier)?.usdPrice ?? "$0.00"
    }

    func coinAmount(for product: SKProduct) -> Int {
        plan(for: product.productIdentifier)?.coins ?? 0
    }

    func plan(for productID: String) -> ProductPlan? { activePlans.first { $0.productID == productID } }

    private func order(for productID: String) -> Int {
        activePlans.firstIndex { $0.productID == productID } ?? Int.max
    }
}

extension InAppPurchaseManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let sortedProducts = response.products
            .filter { self.plan(for: $0.productIdentifier) != nil }
            .sorted { self.order(for: $0.productIdentifier) < self.order(for: $1.productIdentifier) }
        DispatchQueue.main.async { [weak self] in
            self?.products = sortedProducts
            self?.state = .idle
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in self?.state = .failed }
    }
}

extension InAppPurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            transactions.forEach { transaction in
                switch transaction.transactionState {
                case .purchased:
                    if let product = self.products.first(where: { $0.productIdentifier == transaction.payment.productIdentifier }) {
                        AppRepository.shared.addCoins(self.coinAmount(for: product))
                        self.state = .completed(product)
                    }
                    queue.finishTransaction(transaction)
                case .failed:
                    self.state = (transaction.error as? SKError)?.code == .paymentCancelled ? .cancelled : .failed
                    queue.finishTransaction(transaction)
                case .purchasing, .deferred: self.state = .purchasing
                case .restored: queue.finishTransaction(transaction); self.state = .idle
                @unknown default: self.state = .failed
                }
            }
        }
    }
}
