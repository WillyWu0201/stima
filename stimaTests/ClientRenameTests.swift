import Testing
import Foundation
@testable import stima

@Suite("客戶改名連動更新報價單 clientName")
@MainActor
struct ClientRenameTests {

    @Test("改名：只更新相符的報價單，回傳受影響筆數")
    func cascadeUpdatesMatchingQuotes() {
        let q1 = Quote(clientName: "林太太", location: "x", date: .now)
        let q2 = Quote(clientName: "林太太", location: "y", date: .now)
        let q3 = Quote(clientName: "王先生", location: "z", date: .now)
        let n = NewClientSheet.cascadeRename(from: "林太太", to: "林小姐", in: [q1, q2, q3])
        #expect(n == 2)
        #expect(q1.clientName == "林小姐")
        #expect(q2.clientName == "林小姐")
        #expect(q3.clientName == "王先生")   // 不相符者不動
    }

    @Test("同名（沒改）：不動任何資料、回傳 0")
    func cascadeNoopWhenSameName() {
        let q = Quote(clientName: "陳老闆", location: "x", date: .now)
        #expect(NewClientSheet.cascadeRename(from: "陳老闆", to: "陳老闆", in: [q]) == 0)
        #expect(q.clientName == "陳老闆")
    }

    @Test("沒有相符報價單：回傳 0")
    func cascadeNoMatches() {
        let q = Quote(clientName: "A", location: "x", date: .now)
        #expect(NewClientSheet.cascadeRename(from: "B", to: "C", in: [q]) == 0)
        #expect(q.clientName == "A")
    }
}
