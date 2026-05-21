import Testing
import Foundation
@testable import stima

/// LocationSearchCompleter 包 MKLocalSearchCompleter。
/// 真正的搜尋結果靠 Apple 後端 async callback，無法在 unit test 穩定驗證。
/// 這裡只測同步可決定的行為：初始狀態、空查詢 clear results。
@Suite("LocationSearchCompleter · deterministic 行為")
@MainActor
struct LocationSearchCompleterTests {

    @Test("init 後 results 為空")
    func startsEmpty() {
        let c = LocationSearchCompleter()
        #expect(c.results.isEmpty)
    }

    @Test("updateQuery 傳空字串會清空 results")
    func emptyQueryClearsResults() {
        let c = LocationSearchCompleter()
        c.updateQuery("")
        #expect(c.results.isEmpty)
    }

    @Test("updateQuery 傳純空白也視為空")
    func whitespaceOnlyClearsResults() {
        let c = LocationSearchCompleter()
        c.updateQuery("   ")
        #expect(c.results.isEmpty)
    }
}
