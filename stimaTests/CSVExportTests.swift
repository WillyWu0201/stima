import Testing
import Foundation
@testable import stima

/// 用 `.serialized`：QuoteCSV.export 會寫到 temp 目錄且檔名只含日期，
/// 平行執行會互相覆蓋、讀到錯內容。序列化確保每個測試寫完立刻讀。
@Suite("QuoteCSV · CSV 匯出", .serialized)
struct CSVExportTests {

    private func makeQuote(
        client: String = "王先生",
        location: String = "台北",
        status: QuoteStatus = .paid,
        items: [(name: String, unit: String, qty: Double, price: Int)] = [("拆除", "坪", 2, 1000)]
    ) -> Quote {
        let q = Quote(clientName: client, location: location, date: .now, status: status)
        for it in items {
            q.items.append(QuoteItem(name: it.name, unit: it.unit, qty: it.qty, price: it.price))
        }
        q.recalcTotal()
        return q
    }

    @Test("空清單仍產出含 UTF-8 BOM 的表頭")
    func emptyProducesHeaderWithBOM() throws {
        let file = try #require(QuoteCSV.export([]))
        let data = try Data(contentsOf: file.url)
        #expect(data.starts(with: [0xEF, 0xBB, 0xBF]))           // UTF-8 BOM
        let csv = try String(contentsOf: file.url, encoding: .utf8)
        #expect(csv.contains("日期,客戶,地點,狀態,項目數,總計"))
    }

    @Test("每張報價單一列，含客戶 / 狀態 / 項目數 / 總計")
    func rowPerQuote() throws {
        let q = makeQuote(client: "陳先生", status: .paid,
                          items: [("A", "坪", 1, 1000), ("B", "式", 1, 2000)])
        let file = try #require(QuoteCSV.export([q]))
        let csv = try String(contentsOf: file.url, encoding: .utf8)
        #expect(csv.contains("陳先生"))
        #expect(csv.contains("已收款"))            // status 標籤
        #expect(csv.contains(",2,"))               // 項目數 = 2
        #expect(csv.contains(String(q.total)))
    }

    @Test("含逗號的欄位會被雙引號包起來")
    func fieldWithCommaIsQuoted() throws {
        let file = try #require(QuoteCSV.export([makeQuote(client: "A,B 公司")]))
        let csv = try String(contentsOf: file.url, encoding: .utf8)
        #expect(csv.contains("\"A,B 公司\""))
    }

    @Test("含雙引號的欄位：引號跳脫成兩個並整體加引號")
    func fieldWithQuoteIsEscaped() throws {
        let file = try #require(QuoteCSV.export([makeQuote(client: "A\"B")]))
        let csv = try String(contentsOf: file.url, encoding: .utf8)
        #expect(csv.contains("\"A\"\"B\""))         // A"B → "A""B"
    }

    @Test("多張報價單依日期新到舊排序")
    func sortedByDateDescending() throws {
        let older = makeQuote(client: "OLDCLIENT")
        older.date = Date(timeIntervalSince1970: 1_000_000)
        let newer = makeQuote(client: "NEWCLIENT")
        newer.date = Date(timeIntervalSince1970: 2_000_000)
        let file = try #require(QuoteCSV.export([older, newer]))
        let csv = try String(contentsOf: file.url, encoding: .utf8)
        let newPos = try #require(csv.range(of: "NEWCLIENT"))
        let oldPos = try #require(csv.range(of: "OLDCLIENT"))
        #expect(newPos.lowerBound < oldPos.lowerBound)   // 新的在前
    }
}
