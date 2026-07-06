import Foundation

// Single source of truth for free-vs-PRO boundaries.
// To adjust any limit or gate, change it here only.

enum TierConfig {

    // MARK: - Free tier limits

    /// Max quotes a free user can finalize per calendar month.
    static let freeMonthlyQuoteLimit = 3

    // MARK: - PRO features

    /// Features that require a PRO subscription.
    /// Check with `TierConfig.requires(.invoices)`.
    enum ProFeature: CaseIterable {
        case unlimitedQuotes    // >3 finalized quotes/month
        case customPDFTemplate  // logo, stamp, brand color, font
        case removeWatermark    // no "Stima · 免費版" overlay on PDF
        case invoices           // 請款單 (quote → invoice conversion)
        case iCloudSync         // CloudKit backup
        case advancedStats      // net margin, cost tracking
    }

    static func requires(_ feature: ProFeature, isPro: Bool) -> Bool {
        isPro ? false : true  // all ProFeature items are gated; add exceptions here if needed
    }

    // MARK: - PDF watermark

    static let watermarkText    = "Stima · 免費版"
    static let watermarkAngle   = -30.0     // degrees
    static let watermarkOpacity = 0.06

    // MARK: - In-App Purchase product IDs (configure in App Store Connect)

    static let iapMonthlyID = "com.willy.stima.pro_monthly"
    static let iapYearlyID  = "com.willy.stima.pro_yearly"

    /// RevenueCat public SDK key。留空 → PurchaseManager 走開發用 fallback（直接解鎖）。
    /// 填入後台的 key 並加入 RevenueCat SPM 套件即啟用真實購買。詳見 PurchaseManager.swift。
    static let revenueCatAPIKey = ""

    // MARK: - Display prices (fallback until StoreKit loads real prices)

    static let displayMonthlyPrice = "NT$ 299"
    static let displayYearlyPrice  = "NT$ 2,400"
    static let displayYearlySaving = "省 33%"
    static let trialDays = 7
}
