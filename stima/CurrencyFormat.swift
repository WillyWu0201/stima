import SwiftUI

/// 幣別代碼 → 顯示符號。TWD 沿用日常的 "$"（不改台灣觀感），其餘用各自符號。
enum CurrencyFormat {
    static func symbol(for code: String) -> String {
        switch code {
        case "VND": "₫"
        case "IDR": "Rp"
        case "MYR": "RM"
        case "PHP": "₱"
        default:    "$"   // TWD / USD
        }
    }
}

extension AppSettings {
    /// 目前幣別的顯示符號。
    var currencySymbol: String { CurrencyFormat.symbol(for: currency) }
}

/// 讓 leaf view（Money 等）不必層層傳遞就能取得目前幣別符號。
/// 預設 "$"，未注入（如部分 #Preview）時安全 fallback、不會 crash。
private struct CurrencySymbolKey: EnvironmentKey {
    static let defaultValue = "$"
}

extension EnvironmentValues {
    var currencySymbol: String {
        get { self[CurrencySymbolKey.self] }
        set { self[CurrencySymbolKey.self] = newValue }
    }
}
