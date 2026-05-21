import Foundation

/// 免費 / PRO 額度判斷邏輯集中處。所有檢查「能不能再做一張」的地方都走這裡，
/// 之後規則調整只需動一個檔案。
enum TierGate {
    /// 當月（依 referenceDate）已建的 quote 數
    static func currentMonthQuoteCount(
        quotes: [Quote],
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let ref = calendar.dateComponents([.year, .month], from: referenceDate)
        var count = 0
        for q in quotes {
            let c = calendar.dateComponents([.year, .month], from: q.date)
            if c.year == ref.year && c.month == ref.month {
                count += 1
            }
        }
        return count
    }

    /// 能不能再建一張 quote。PRO 永遠 true，免費版要看當月配額。
    static func canCreateQuote(
        isPro: Bool,
        quotes: [Quote],
        referenceDate: Date = .now
    ) -> Bool {
        guard !isPro else { return true }
        return currentMonthQuoteCount(quotes: quotes,
                                      referenceDate: referenceDate)
            < TierConfig.freeMonthlyQuoteLimit
    }

    /// 還剩幾張免費額度（PRO 回傳 nil 表示沒有上限）。
    static func remainingFreeQuotes(
        isPro: Bool,
        quotes: [Quote],
        referenceDate: Date = .now
    ) -> Int? {
        guard !isPro else { return nil }
        let used = currentMonthQuoteCount(quotes: quotes, referenceDate: referenceDate)
        return max(0, TierConfig.freeMonthlyQuoteLimit - used)
    }
}
