import Testing
import Foundation
@testable import stima

@Suite("ShareMessage · 分享訊息格式")
struct ShareMessageTests {

    private func sampleQuote() -> Quote {
        let comp = DateComponents(year: 2026, month: 5, day: 15)
        let date = Calendar.current.date(from: comp) ?? .now
        let q = Quote(clientName: "王先生", location: "台北市信義區",
                      date: date, status: .ongoing)
        q.items.append(QuoteItem(name: "A", unit: "坪", qty: 10, price: 1000))
        q.items.append(QuoteItem(name: "B", unit: "式", qty: 1, price: 5000))
        q.recalcTotal()
        return q
    }

    @Test("forQuote 含客戶 / 日期 / 地點 / 項目數 / 總金額 / 抬頭")
    func quoteMessageContainsExpectedFields() {
        let q = sampleQuote()
        let msg = ShareMessage.forQuote(q, masterName: "陳師傅")
        #expect(msg.contains("【報價單】王先生"))
        #expect(msg.contains("2026-05-15"))
        #expect(msg.contains("台北市信義區"))
        #expect(msg.contains("項目共 2 筆"))
        #expect(msg.contains("$"))
        #expect(msg.contains("\(q.total.formatted())"))
        #expect(msg.contains("陳師傅"))
    }

    @Test("forQuote 沒抬頭時不附簽名行")
    func quoteMessageOmitsSignOffWhenMasterNameEmpty() {
        let msg = ShareMessage.forQuote(sampleQuote(), masterName: "")
        #expect(!msg.contains("陳師傅"))
        // 仍然要有基本欄位
        #expect(msg.contains("【報價單】"))
    }

    @Test("forQuote 沒地點時跳過地點行")
    func quoteMessageOmitsLocationWhenEmpty() {
        let q = sampleQuote()
        q.location = ""
        let msg = ShareMessage.forQuote(q, masterName: "陳師傅")
        #expect(!msg.contains("地點："))
        #expect(msg.contains("【報價單】"))
    }

    @Test("forInvoice 標籤是「請款單」+ 到期日")
    func invoiceMessageLabelsAndDueDate() {
        let q = sampleQuote()
        q.dueDate = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 14))
        let msg = ShareMessage.forInvoice(q, masterName: "陳師傅")
        #expect(msg.contains("【請款單】王先生"))
        #expect(msg.contains("請款金額："))
        #expect(msg.contains("2026-06-14"))
    }

    @Test("forInvoice 沒設 dueDate 時用「—」")
    func invoiceMessageHandlesMissingDueDate() {
        let q = sampleQuote()
        q.dueDate = nil
        let msg = ShareMessage.forInvoice(q, masterName: "")
        #expect(msg.contains("付款到期日：—"))
    }
}
