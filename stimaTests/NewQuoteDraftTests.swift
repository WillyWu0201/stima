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

    // MARK: - 編輯既有報價單（from / apply）

    @Test("from(quote)：映射既有報價單欄位與項目（含成本）")
    func fromQuoteMapsFields() {
        let q = Quote(clientName: "王先生", location: "台北市信義區",
                      date: .now, folder: "2026", status: .ongoing)
        q.items.append(QuoteItem(name: "拆除磁磚", unit: "坪", qty: 10, price: 1800, cost: 900))
        let d = NewQuoteDraft.from(q)
        #expect(d.clientName == "王先生")
        #expect(d.location == "台北市信義區")
        #expect(d.folder == "2026")
        #expect(d.items.count == 1)
        #expect(d.items[0].name == "拆除磁磚")
        #expect(d.items[0].price == 1800)
        #expect(d.items[0].cost == 900)
    }

    @Test("apply(to:)：就地更新既有報價單、重算 total、保留 id 與 status")
    func applyUpdatesQuoteInPlace() {
        let q = Quote(clientName: "舊客戶", location: "舊地點", status: .ongoing)
        q.items.append(QuoteItem(name: "X", unit: "式", qty: 1, price: 100))
        let originalID = q.id
        let d = NewQuoteDraft()
        d.clientName = "新客戶"
        d.location = "新地點"
        d.items = [.init(name: "A", unit: "坪", qty: 2, price: 1000, cost: 300)]
        d.apply(to: q, taxRatePercent: 5)
        #expect(q.id == originalID)                          // id 不變
        #expect(q.clientName == "新客戶")
        #expect(q.location == "新地點")
        #expect(q.items.count == 1)
        #expect(q.items[0].name == "A")
        #expect(q.items[0].cost == 300)
        #expect(q.status == QuoteStatus.ongoing.rawValue)    // status 保留
        #expect(q.total == 2100)                             // 2000 + 5% 稅 = 2100
    }

    @Test("apply：空客戶名 → 未命名客戶")
    func applyEmptyClientNameFallback() {
        let q = Quote(clientName: "舊")
        let d = NewQuoteDraft()   // clientName = ""
        d.apply(to: q)
        #expect(q.clientName == "未命名客戶")
    }
}
