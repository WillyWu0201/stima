import Foundation
#if canImport(RevenueCat)
import RevenueCat
#endif

/// 訂閱購買管理（RevenueCat）。
///
/// 用 `#if canImport(RevenueCat)` 包住：**沒裝 SDK 時整段 fallback**（直接切 `isPro`，方便開發/測試），
/// 專案照常編譯。裝了 SDK 並填好 API key 後就自動走真實購買流程，不需要改其他程式碼。
///
/// 要啟用真實購買，做三件事：
/// 1. Xcode → File → Add Package Dependencies → `https://github.com/RevenueCat/purchases-ios`
/// 2. 把 `TierConfig.revenueCatAPIKey` 換成 RevenueCat 後台的 public SDK key
/// 3. RevenueCat 後台建立 entitlement「pro」，掛上 `TierConfig.iapMonthlyID` / `iapYearlyID` 兩個商品
@MainActor
final class PurchaseManager {
    static let shared = PurchaseManager()
    private init() {}

    /// RevenueCat entitlement 識別字（需與後台一致）。
    static let entitlementID = "pro"

    private var isConfigured: Bool {
        !TierConfig.revenueCatAPIKey.isEmpty
    }

    /// App 啟動時呼叫一次。
    func configure() {
        #if canImport(RevenueCat)
        guard isConfigured else { return }
        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: TierConfig.revenueCatAPIKey)
        #endif
    }

    /// 從 RevenueCat 把訂閱狀態同步進 AppSettings（啟動時、回到前景時可呼叫）。
    func syncEntitlement(into settings: AppSettings) async {
        #if canImport(RevenueCat)
        guard isConfigured else { return }
        if let info = try? await Purchases.shared.customerInfo() {
            settings.isPro = info.entitlements[Self.entitlementID]?.isActive == true
        }
        #endif
    }

    func purchaseYearly(into settings: AppSettings) async -> Bool {
        await purchase(productID: TierConfig.iapYearlyID, into: settings)
    }

    func purchaseMonthly(into settings: AppSettings) async -> Bool {
        await purchase(productID: TierConfig.iapMonthlyID, into: settings)
    }

    func restore(into settings: AppSettings) async -> Bool {
        #if canImport(RevenueCat)
        if isConfigured {
            if let info = try? await Purchases.shared.restorePurchases() {
                let active = info.entitlements[Self.entitlementID]?.isActive == true
                settings.isPro = active
                return active
            }
            return false
        }
        #endif
        return mockUnlock(settings)
    }

    private func purchase(productID: String, into settings: AppSettings) async -> Bool {
        #if canImport(RevenueCat)
        if isConfigured {
            let products = await Purchases.shared.products([productID])
            guard let product = products.first else { return false }
            do {
                let result = try await Purchases.shared.purchase(product: product)
                let active = result.customerInfo.entitlements[Self.entitlementID]?.isActive == true
                settings.isPro = active
                return active
            } catch {
                return false
            }
        }
        #endif
        return mockUnlock(settings)
    }

    /// 沒接 SDK 時的開發用 fallback：直接解鎖。
    private func mockUnlock(_ settings: AppSettings) -> Bool {
        settings.isPro = true
        return true
    }
}
