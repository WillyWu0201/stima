import Testing
import Foundation
@testable import stima

@Suite("Client model · init")
struct ClientTests {

    @Test("只給 name：其餘欄位為空，lastContact 約為現在")
    func defaults() {
        let c = Client(name: "王先生")
        #expect(c.name == "王先生")
        #expect(c.phone.isEmpty)
        #expect(c.email.isEmpty)
        #expect(c.address.isEmpty)
        #expect(c.notes.isEmpty)
        #expect(abs(c.lastContact.timeIntervalSinceNow) < 5)
    }

    @Test("完整欄位都正確帶入")
    func allFields() {
        let c = Client(name: "陳小姐", phone: "0912345678", email: "a@b.com",
                       address: "台北市信義區", notes: "老客戶")
        #expect(c.phone == "0912345678")
        #expect(c.email == "a@b.com")
        #expect(c.address == "台北市信義區")
        #expect(c.notes == "老客戶")
    }

    @Test("每個 Client 各有不同 id")
    func uniqueIDs() {
        #expect(Client(name: "A").id != Client(name: "B").id)
    }
}

@Suite("CustomItem model · init")
struct CustomItemTests {

    @Test("欄位正確帶入")
    func fields() {
        let item = CustomItem(name: "拆除磁磚", unit: "坪", price: 1800, category: "拆除")
        #expect(item.name == "拆除磁磚")
        #expect(item.unit == "坪")
        #expect(item.price == 1800)
        #expect(item.category == "拆除")
    }
}
