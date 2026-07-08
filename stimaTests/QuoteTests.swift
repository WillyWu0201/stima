import Testing
import Foundation
@testable import stima

@Suite("Quote model · 金額計算 / 狀態 enum")
struct QuoteTests {

    @Test("recalcTotal 含 5% 稅金（預設）")
    func recalcDefaultTax() {
        let q = Quote(clientName: "x", location: "", date: .now)
        q.items.append(QuoteItem(name: "A", unit: "個", qty: 2, price: 1000))   // 2,000
        q.items.append(QuoteItem(name: "B", unit: "坪", qty: 5, price: 500))    // 2,500
        q.recalcTotal()
        // subtotal 4500, tax 225, total 4725
        #expect(q.total == 4725)
    }

    @Test("recalcTotal 可指定其他稅率")
    func recalcCustomTax() {
        let q = Quote(clientName: "x", location: "", date: .now)
        q.items.append(QuoteItem(name: "A", unit: "個", qty: 1, price: 1000))
        q.recalcTotal(taxRatePercent: 10)
        #expect(q.total == 1100)
    }

    @Test("空 items 的 recalcTotal 是 0")
    func recalcEmpty() {
        let q = Quote(clientName: "x", location: "", date: .now)
        q.recalcTotal()
        #expect(q.total == 0)
    }

    @Test("QuoteItem.subtotal = qty × price")
    func itemSubtotal() {
        let item = QuoteItem(name: "拆除", unit: "坪", qty: 10, price: 1800)
        #expect(item.subtotal == 18_000)
    }

    @Test("QuoteItem.subtotal 對小數 qty 取整數部分")
    func itemSubtotalRoundsQty() {
        // 目前 implementation 是 Int(qty) × price，所以 2.7 → 2
        let item = QuoteItem(name: "x", unit: "個", qty: 2.7, price: 100)
        #expect(item.subtotal == 200)
    }

    @Test("Quote 預設 status 是 .draft")
    func defaultStatusIsDraft() {
        let q = Quote(clientName: "x", location: "", date: .now)
        #expect(q.quoteStatus == .draft)
    }

    @Test("quoteStatus 從 rawValue 回讀")
    func quoteStatusRoundTrip() {
        let q = Quote(clientName: "x", location: "", date: .now, status: .paid)
        #expect(q.quoteStatus == .paid)
    }

    @Test("不認得的 status rawValue 回 .draft")
    func unknownStatusFallsBackToDraft() {
        let q = Quote(clientName: "x", location: "", date: .now)
        q.status = "garbage"
        #expect(q.quoteStatus == .draft)
    }

    @Test(arguments: [
        (QuoteStatus.draft,   "草稿"),
        (QuoteStatus.ongoing, "進行中"),
        (QuoteStatus.done,    "已完工"),
        (QuoteStatus.paid,    "已收款"),
    ])
    func statusLabel(_ status: QuoteStatus, _ expected: String) {
        #expect(status.label == expected)
    }

    @Test("QuoteItem.costSubtotal = Int(qty) × cost；cost 預設 0")
    func itemCostSubtotal() {
        #expect(QuoteItem(name: "x", unit: "式", qty: 3, price: 1000, cost: 200).costSubtotal == 600)
        #expect(QuoteItem(name: "x", unit: "式", qty: 1, price: 100).cost == 0)
    }
}
