import Foundation

/// 全域使用者設定的單一來源。注入到 root view 後，子畫面透過 @Environment 取用。
/// 所有值都持久化到 UserDefaults，App 重啟後自動還原。
@Observable
final class AppSettings {

    // MARK: - Onboarding
    var hasSeenOnboarding: Bool = UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding) {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    // MARK: - 訂閱狀態
    var isPro: Bool = UserDefaults.standard.bool(forKey: Keys.isPro) {
        didSet { UserDefaults.standard.set(isPro, forKey: Keys.isPro) }
    }

    // MARK: - 師傅資料
    /// 報價單抬頭（第一次出單時詢問，之後自動帶入）
    var masterName: String = UserDefaults.standard.string(forKey: Keys.masterName) ?? "" {
        didSet { UserDefaults.standard.set(masterName, forKey: Keys.masterName) }
    }

    // MARK: - 商務設定
    var taxRate: Double = {
        let v = UserDefaults.standard.double(forKey: Keys.taxRate)
        return v == 0 ? 5.0 : v
    }() {
        didSet { UserDefaults.standard.set(taxRate, forKey: Keys.taxRate) }
    }

    var currency: String = UserDefaults.standard.string(forKey: Keys.currency) ?? Currency.twd {
        didSet { UserDefaults.standard.set(currency, forKey: Keys.currency) }
    }

    var language: String = UserDefaults.standard.string(forKey: Keys.language) ?? Language.zhHant {
        didSet { UserDefaults.standard.set(language, forKey: Keys.language) }
    }

    /// 項目分類標籤（第一個永遠是「常用」，不可刪除）
    var categories: [String] = (UserDefaults.standard.array(forKey: Keys.categories) as? [String])
        ?? ["常用", "拆除", "水電", "泥作", "木作"] {
        didSet { UserDefaults.standard.set(categories, forKey: Keys.categories) }
    }

    // MARK: - 字體縮放
    var fontScale: Double = {
        let v = UserDefaults.standard.double(forKey: Keys.fontScale)
        return v == 0 ? 1.0 : v
    }() {
        didSet { UserDefaults.standard.set(fontScale, forKey: Keys.fontScale) }
    }
}

// MARK: - 常數

extension AppSettings {

    enum Currency {
        static let twd = "TWD"
        static let all = ["TWD", "VND", "IDR", "USD", "MYR", "PHP"]
    }

    enum Language {
        static let zhHant = "zh-Hant"
        static let all = ["zh-Hant", "zh-Hans", "en", "vi", "id"]
    }

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let isPro             = "isPro"
        static let masterName        = "masterName"
        static let taxRate           = "taxRate"
        static let currency          = "currency"
        static let language          = "language"
        static let categories        = "categories"
        static let fontScale         = "fontScale"
    }
}
