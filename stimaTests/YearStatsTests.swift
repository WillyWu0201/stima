import Testing
import Foundation
@testable import stima

@Suite("YearStatsCalculator · 統計推導")
struct YearStatsTests {

    /// 建一張固定日期的 quote（year/month/day），insert items 並算好 total。
    private func makeQuote(
        year: Int, month: Int, day: Int = 15,
        client: String = "客戶",
        status: QuoteStatus,
        items: [(name: String, unit: String, qty: Double, price: Int)] = [("A", "式", 1, 1000)]
    ) -> Quote {
        let comp = DateComponents(year: year, month: month, day: day)
        let date = Calendar.current.date(from: comp) ?? .now
        let q = Quote(clientName: client, location: "x", date: date, status: status)
        for it in items {
            q.items.append(QuoteItem(name: it.name, unit: it.unit, qty: it.qty, price: it.price))
        }
        q.recalcTotal()
        return q
    }

    @Test
    func emptyQuotesProducesZeros() {
        let stats = YearStatsCalculator.compute(quotes: [], year: 2026)
        #expect(stats.total == 0)
        #expect(stats.paidCount == 0)
        #expect(stats.paidTotal == 0)
        #expect(stats.monthly == Array(repeating: 0, count: 12))
        #expect(stats.maxMonthly == 1)   // floor 1 避免除以 0
        #expect(stats.topClient == nil)
        #expect(stats.topItems.isEmpty)
        #expect(stats.prevYearPaid == nil)
    }

    @Test("正確分類 paid / done / ongoing 並計加總")
    func classifiesByStatus() {
        let quotes = [
            makeQuote(year: 2026, month: 5,  status: .paid),
            makeQuote(year: 2026, month: 5,  status: .paid),
            makeQuote(year: 2026, month: 6,  status: .done),
            makeQuote(year: 2026, month: 7,  status: .ongoing),
            makeQuote(year: 2026, month: 7,  status: .ongoing),
            makeQuote(year: 2026, month: 8,  status: .draft),     // draft 不算進任何 bucket
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)

        #expect(s.total == 6)
        #expect(s.paidCount == 2)
        #expect(s.doneCount == 1)
        #expect(s.ongoingCount == 2)
        #expect(s.paidTotal == 2100)        // 2 × (1050 含稅)
        #expect(s.doneTotal == 1050)
        #expect(s.ongoingTotal == 2100)
    }

    @Test("monthly array 只統計 paid，正確分到對應月份")
    func monthlyOnlyCountsPaid() {
        let quotes = [
            makeQuote(year: 2026, month: 2, status: .paid),
            makeQuote(year: 2026, month: 2, status: .paid),
            makeQuote(year: 2026, month: 5, status: .paid),
            makeQuote(year: 2026, month: 5, status: .ongoing),    // 進行中不算
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)

        #expect(s.monthly[0]  == 0)       // 1 月
        #expect(s.monthly[1]  == 2100)    // 2 月：2 × 1050
        #expect(s.monthly[4]  == 1050)    // 5 月：1 × 1050
        #expect(s.monthly[11] == 0)       // 12 月
        #expect(s.maxMonthly == 2100)
    }

    @Test("不同年的 quotes 不會混入")
    func filtersByYear() {
        let quotes = [
            makeQuote(year: 2025, month: 5, status: .paid),
            makeQuote(year: 2026, month: 5, status: .paid),
            makeQuote(year: 2027, month: 5, status: .paid),
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)
        #expect(s.total == 1)
        #expect(s.paidCount == 1)
    }

    @Test("prevYearPaid 抓上一年的 paid 加總（沒資料時為 nil）")
    func prevYearPaid() {
        let quotes = [
            makeQuote(year: 2025, month: 3, status: .paid),
            makeQuote(year: 2025, month: 6, status: .paid),
            makeQuote(year: 2026, month: 1, status: .paid),
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)
        #expect(s.prevYearPaid == 2100)        // 2 張 × 1050

        let none = YearStatsCalculator.compute(quotes: quotes, year: 2025)
        #expect(none.prevYearPaid == nil)      // 2024 沒資料
    }

    @Test("topClient 由 paid total 排序")
    func topClientByPaidTotal() throws {
        let quotes = [
            // A 一張 paid（5250）
            makeQuote(year: 2026, month: 1, client: "A", status: .paid,
                      items: [("x", "式", 1, 5000)]),
            // B 兩張 paid（合計 10500）
            makeQuote(year: 2026, month: 2, client: "B", status: .paid,
                      items: [("x", "式", 1, 5000)]),
            makeQuote(year: 2026, month: 3, client: "B", status: .paid,
                      items: [("x", "式", 1, 5000)]),
            // A 一張 ongoing — 不算進 paid total，但會算進 count
            makeQuote(year: 2026, month: 4, client: "A", status: .ongoing,
                      items: [("x", "式", 1, 99999)]),
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)
        let top = try #require(s.topClient)
        #expect(top.name == "B")
        #expect(top.count == 2)
        // B 的 paid total = (5000 × 1.05) × 2 = 10500
        #expect(top.total == 10500)
    }

    @Test("topItems 依 count 排序、取前 5")
    func topItemsByCount() {
        let quotes = [
            makeQuote(year: 2026, month: 1, status: .paid, items: [("A", "坪", 1, 100)]),
            makeQuote(year: 2026, month: 2, status: .paid, items: [("A", "坪", 1, 100)]),
            makeQuote(year: 2026, month: 3, status: .paid, items: [("A", "坪", 1, 100), ("B", "式", 1, 200)]),
            makeQuote(year: 2026, month: 4, status: .paid, items: [("C", "個", 1, 50)]),
        ]
        let s = YearStatsCalculator.compute(quotes: quotes, year: 2026)
        #expect(s.topItems.first?.name == "A")
        #expect(s.topItems.first?.count == 3)
    }

    @Test
    func availableYearsSortedDescending() {
        let quotes = [
            makeQuote(year: 2024, month: 1, status: .paid),
            makeQuote(year: 2026, month: 1, status: .paid),
            makeQuote(year: 2025, month: 1, status: .paid),
        ]
        #expect(YearStatsCalculator.availableYears(quotes: quotes) == [2026, 2025, 2024])
    }

    // MARK: - YearStats struct（yoyPercent / TopItem.id）

    /// 直接建構 YearStats 來測 yoyPercent —— compute 不會產出 prevYearPaid == 0
    /// （它會轉成 nil），所以那個分支只能手動建構來覆蓋。
    private func stats(paidTotal: Int, prevYearPaid: Int?, costTotal: Int = 0) -> YearStats {
        YearStats(total: 0, paidCount: 0, doneCount: 0, ongoingCount: 0,
                  paidTotal: paidTotal, doneTotal: 0, ongoingTotal: 0,
                  monthly: Array(repeating: 0, count: 12), maxMonthly: 1,
                  topClient: nil, topItems: [], prevYearPaid: prevYearPaid,
                  costTotal: costTotal)
    }

    @Test("yoyPercent：今年 200 / 去年 100 → +100%")
    func yoyPositive() throws {
        let pct = try #require(stats(paidTotal: 200, prevYearPaid: 100).yoyPercent)
        #expect(abs(pct - 100) < 0.001)
    }

    @Test("yoyPercent：衰退為負值")
    func yoyNegative() throws {
        let pct = try #require(stats(paidTotal: 50, prevYearPaid: 100).yoyPercent)
        #expect(abs(pct + 50) < 0.001)
    }

    @Test("yoyPercent：去年 nil 或 0 時為 nil")
    func yoyNilWhenNoBaseline() {
        #expect(stats(paidTotal: 200, prevYearPaid: nil).yoyPercent == nil)
        #expect(stats(paidTotal: 200, prevYearPaid: 0).yoyPercent == nil)
    }

    @Test("TopItem.id 就是品項名稱")
    func topItemIDIsName() {
        let item = YearStats.TopItem(name: "拆除磁磚", count: 3, totalQty: 5, totalRev: 9000, unit: "坪")
        #expect(item.id == "拆除磁磚")
    }

    // MARK: - 成本 / 淨利

    @Test("netProfit = 營收 − 成本；marginPercent 正確")
    func netProfitAndMargin() throws {
        let s = stats(paidTotal: 1000, prevYearPaid: nil, costTotal: 600)
        #expect(s.netProfit == 400)
        let m = try #require(s.marginPercent)
        #expect(abs(m - 40) < 0.001)
    }

    @Test("沒填成本（costTotal 0）時 marginPercent 為 nil")
    func marginNilWhenNoCost() {
        #expect(stats(paidTotal: 1000, prevYearPaid: nil, costTotal: 0).marginPercent == nil)
    }

    @Test("compute 只從『已收款』的項目累計成本")
    func computeCostTotalFromPaidOnly() {
        let paidQ = makeQuote(year: 2026, month: 5, status: .paid,
                              items: [("A", "式", 2, 1000), ("B", "坪", 3, 500)])
        paidQ.items[0].cost = 600     // ×2 = 1200
        paidQ.items[1].cost = 200     // ×3 = 600
        let ongoingQ = makeQuote(year: 2026, month: 6, status: .ongoing,
                                 items: [("C", "式", 1, 9999)])
        ongoingQ.items[0].cost = 8000 // 進行中不該被算進成本
        let s = YearStatsCalculator.compute(quotes: [paidQ, ongoingQ], year: 2026)
        #expect(s.costTotal == 1800)
        #expect(s.netProfit == s.paidTotal - 1800)
    }
}
