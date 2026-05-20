import Foundation

/// 內建的項目庫，給加項目 picker 用。
/// 未來會跟 SwiftData 的 CustomItem 合併（使用者自訂的項目會以分類混入這份資料）。
enum ItemLibrary {
    struct Entry: Hashable, Identifiable {
        var id: String { "\(category)_\(name)" }
        let category: String
        let name: String
        let unit: String
        let lastPrice: Int
        var usedCount: Int? = nil
    }

    static let categoryOrder: [String] = ["常用", "拆除", "水電", "泥作", "木作"]

    static let entries: [Entry] = [
        // 常用（依使用頻率）
        .init(category: "常用", name: "拆除磁磚",   unit: "坪", lastPrice: 1800,  usedCount: 42),
        .init(category: "常用", name: "泥作粉光",   unit: "坪", lastPrice: 2500,  usedCount: 38),
        .init(category: "常用", name: "水電配管",   unit: "式", lastPrice: 35000, usedCount: 35),
        .init(category: "常用", name: "油漆批土",   unit: "坪", lastPrice: 850,   usedCount: 31),
        .init(category: "常用", name: "木作天花板", unit: "坪", lastPrice: 3200,  usedCount: 28),

        // 拆除
        .init(category: "拆除", name: "拆除磁磚",     unit: "坪", lastPrice: 1800),
        .init(category: "拆除", name: "拆除木作",     unit: "坪", lastPrice: 1500),
        .init(category: "拆除", name: "拆除隔間牆",   unit: "坪", lastPrice: 2200),

        // 水電
        .init(category: "水電", name: "水電配管",     unit: "式", lastPrice: 35000),
        .init(category: "水電", name: "新增插座",     unit: "個", lastPrice: 1200),
        .init(category: "水電", name: "燈具安裝",     unit: "組", lastPrice: 800),
        .init(category: "水電", name: "冷氣排水管",   unit: "式", lastPrice: 3500),

        // 泥作
        .init(category: "泥作", name: "泥作粉光",     unit: "坪", lastPrice: 2500),
        .init(category: "泥作", name: "貼磁磚",       unit: "坪", lastPrice: 2800),
        .init(category: "泥作", name: "防水工程",     unit: "坪", lastPrice: 1800),

        // 木作
        .init(category: "木作", name: "木作天花板",   unit: "坪", lastPrice: 3200),
        .init(category: "木作", name: "系統櫃",       unit: "尺", lastPrice: 4500),
        .init(category: "木作", name: "木地板施作",   unit: "坪", lastPrice: 4800),
    ]

    static func entries(in category: String) -> [Entry] {
        entries.filter { $0.category == category }
    }

    static let units: [String] = ["坪", "式", "個", "組", "尺", "車", "人/日"]
}
