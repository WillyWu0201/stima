import Testing
@testable import stima

@Suite("InvoicePayment · 收款資訊拆行")
struct InvoicePaymentTests {

    @Test("多行文字拆成非空行")
    func splitsNonEmptyLines() {
        let raw = "匯款：玉山\nLINE Pay\n現金"
        #expect(InvoicePayment.lines(from: raw) == ["匯款：玉山", "LINE Pay", "現金"])
    }

    @Test("去頭尾空白、丟掉空行")
    func trimsAndDropsBlankLines() {
        let raw = "  匯款：玉山  \n\n   \n LINE Pay \n"
        #expect(InvoicePayment.lines(from: raw) == ["匯款：玉山", "LINE Pay"])
    }

    @Test("空字串 / 全空白 → 空陣列（請款單隱藏付款方式）")
    func emptyYieldsEmpty() {
        #expect(InvoicePayment.lines(from: "").isEmpty)
        #expect(InvoicePayment.lines(from: "   \n  \n\t").isEmpty)
    }
}
