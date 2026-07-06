import Testing
import Foundation
@testable import stima

@Suite("NewQuoteDraft · draft 金額計算")
@MainActor
struct NewQuoteDraftTests {

    @Test("空 items：subtotal/tax/total 皆 0")
    func emptyDraft() {
        let d = NewQuoteDraft()
        #expect(d.subtotal == 0)
        #expect(d.tax() == 0)
        #expect(d.total() == 0)
    }

    @Test("subtotal = 所有 Item.subtotal 加總")
    func subtotalAggregates() {
        let d = NewQuoteDraft()
        d.items = [
            .init(name: "A", unit: "個", qty: 2, price: 1000),    // 2000
            .init(name: "B", unit: "坪", qty: 5, price: 500),     // 2500
        ]
        #expect(d.subtotal == 4500)
    }

    @Test("tax 預設 5%，四捨五入")
    func defaultTax() {
        let d = NewQuoteDraft()
        d.items = [
            .init(name: "x", unit: "式", qty: 1, price: 12345),
        ]
        // 12345 × 0.05 = 617.25 → round → 617
        #expect(d.tax() == 617)
    }

    @Test("自訂稅率")
    func customTaxRate() {
        let d = NewQuoteDraft()
        d.items = [.init(name: "x", unit: "式", qty: 1, price: 10000)]
        #expect(d.tax(ratePercent: 10) == 1000)
        #expect(d.total(ratePercent: 10) == 11000)
    }

    @Test("Item.subtotal = Int(qty) × price（目前 implementation 對小數 qty 取整）")
    func itemSubtotalRoundsQty() {
        let item = NewQuoteDraft.Item(name: "x", unit: "個", qty: 2.7, price: 100)
        #expect(item.subtotal == 200)
    }

    @Test("Item 各自不同 id，equatable 依 id+欄位")
    func itemIDsAreUnique() {
        let a = NewQuoteDraft.Item(name: "x", unit: "個", qty: 1, price: 100)
        let b = NewQuoteDraft.Item(name: "x", unit: "個", qty: 1, price: 100)
        #expect(a.id != b.id)
        #expect(a != b)
    }
}
