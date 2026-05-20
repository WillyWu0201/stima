import Foundation

/// 一個年度的統計資料，從 quotes 推導。Stats 畫面用。
struct YearStats {
    let total: Int               // 該年總張數
    let paidCount: Int
    let doneCount: Int
    let ongoingCount: Int
    let paidTotal: Int           // 已收款總額
    let doneTotal: Int           // 已完工但未收款
    let ongoingTotal: Int        // 進行中
    let monthly: [Int]           // 12 個月的已收款
    let maxMonthly: Int          // 至少 1，避免除以 0
    let topClient: TopClient?
    let topItems: [TopItem]
    let prevYearPaid: Int?       // 去年已收款（沒資料時為 nil）

    struct TopClient: Equatable {
        let name: String
        let count: Int
        let total: Int
    }

    struct TopItem: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let count: Int
        let totalQty: Double
        let totalRev: Int
        let unit: String
    }

    /// YoY 變化百分比（去年資料時為 nil）
    var yoyPercent: Double? {
        guard let prev = prevYearPaid, prev > 0 else { return nil }
        return Double(paidTotal - prev) / Double(prev) * 100
    }
}

enum YearStatsCalculator {
    static func compute(quotes: [Quote], year: Int, calendar: Calendar = .current) -> YearStats {
        let yearQuotes     = quotes.filter { calendar.component(.year, from: $0.date) == year }
        let prevYearQuotes = quotes.filter { calendar.component(.year, from: $0.date) == year - 1 }

        let paid    = yearQuotes.filter { $0.quoteStatus == .paid }
        let done    = yearQuotes.filter { $0.quoteStatus == .done }
        let ongoing = yearQuotes.filter { $0.quoteStatus == .ongoing }

        // 月份 bar
        var monthly = Array(repeating: 0, count: 12)
        for q in paid {
            let m = calendar.component(.month, from: q.date) - 1
            if (0..<12).contains(m) { monthly[m] += q.total }
        }
        let maxMonthly = max(monthly.max() ?? 0, 1)

        // 最大客戶（用 paid total 排序）
        var clientCount: [String: Int] = [:]
        var clientTotal: [String: Int] = [:]
        for q in yearQuotes {
            clientCount[q.clientName, default: 0] += 1
            if q.quoteStatus == .paid {
                clientTotal[q.clientName, default: 0] += q.total
            }
        }
        let topClient: YearStats.TopClient? = clientTotal
            .max { $0.value < $1.value }
            .map { .init(name: $0.key, count: clientCount[$0.key] ?? 0, total: $0.value) }

        // 最常做的項目（用 count 排序，取前 5）
        var itemAgg: [String: (count: Int, qty: Double, rev: Int, unit: String)] = [:]
        for q in yearQuotes {
            for it in q.items {
                var e = itemAgg[it.name] ?? (0, 0, 0, it.unit)
                e.count += 1
                e.qty   += it.qty
                e.rev   += it.subtotal
                e.unit  = it.unit
                itemAgg[it.name] = e
            }
        }
        let topItems: [YearStats.TopItem] = itemAgg
            .sorted { $0.value.count > $1.value.count }
            .prefix(5)
            .map { .init(name: $0.key, count: $0.value.count, totalQty: $0.value.qty,
                         totalRev: $0.value.rev, unit: $0.value.unit) }

        let prevPaid = prevYearQuotes
            .filter { $0.quoteStatus == .paid }
            .reduce(0) { $0 + $1.total }

        return YearStats(
            total:        yearQuotes.count,
            paidCount:    paid.count,
            doneCount:    done.count,
            ongoingCount: ongoing.count,
            paidTotal:    paid.reduce(0) { $0 + $1.total },
            doneTotal:    done.reduce(0) { $0 + $1.total },
            ongoingTotal: ongoing.reduce(0) { $0 + $1.total },
            monthly:      monthly,
            maxMonthly:   maxMonthly,
            topClient:    topClient,
            topItems:     topItems,
            prevYearPaid: prevPaid > 0 ? prevPaid : nil
        )
    }

    static func availableYears(quotes: [Quote], calendar: Calendar = .current) -> [Int] {
        let set = Set(quotes.map { calendar.component(.year, from: $0.date) })
        return set.sorted(by: >)
    }
}

enum MonthLabel {
    static let zhHant = ["1月","2月","3月","4月","5月","6月","7月","8月","9月","10月","11月","12月"]
}
