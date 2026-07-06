import Testing
import Foundation
@testable import stima

@Suite("CurrencyFormat · 幣別符號 / 套用")
struct CurrencyFormatTests {

    @Test("各幣別對到正確符號；未知代碼 fallback $")
    func symbols() {
        #expect(CurrencyFormat.symbol(for: "TWD") == "$")
        #expect(CurrencyFormat.symbol(for: "USD") == "$")
        #expect(CurrencyFormat.symbol(for: "VND") == "₫")
        #expect(CurrencyFormat.symbol(for: "IDR") == "Rp")
        #expect(CurrencyFormat.symbol(for: "MYR") == "RM")
        #expect(CurrencyFormat.symbol(for: "PHP") == "₱")
        #expect(CurrencyFormat.symbol(for: "???") == "$")
    }

    @Test("ShareMessage 用傳入的幣別符號、不再寫死 NT$")
    func shareMessageUsesGivenSymbol() {
        let q = Quote(clientName: "王先生", location: "", date: .now)
        q.items.append(QuoteItem(name: "x", unit: "式", qty: 1, price: 10000))
        q.recalcTotal()
        let msg = ShareMessage.forQuote(q, masterName: "", currencySymbol: "₫")
        #expect(msg.contains("₫"))
        #expect(!msg.contains("NT$"))
    }
}
