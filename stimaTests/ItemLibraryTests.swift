import Testing
@testable import stima

@Suite("ItemLibrary · 內建項目庫")
struct ItemLibraryTests {

    @Test("entries(in:) 只回傳該分類的項目")
    func filterByCategory() {
        let water = ItemLibrary.entries(in: "水電")
        #expect(!water.isEmpty)
        #expect(water.allSatisfy { $0.category == "水電" })
    }

    @Test("未知分類回傳空陣列")
    func unknownCategoryEmpty() {
        #expect(ItemLibrary.entries(in: "不存在的分類").isEmpty)
    }

    @Test("Entry.id 為「分類_名稱」；usedCount 預設 nil")
    func entryIdentity() {
        let e = ItemLibrary.Entry(category: "水電", name: "新增插座", unit: "個", lastPrice: 1200)
        #expect(e.id == "水電_新增插座")
        #expect(e.usedCount == nil)
    }

    @Test("categoryOrder 第一個永遠是「常用」")
    func categoryOrderStartsWithCommon() {
        #expect(ItemLibrary.categoryOrder.first == "常用")
    }
}
