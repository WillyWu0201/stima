import SwiftData
import Foundation

/// SwiftUI #Preview 用的 in-memory 資料。
/// 資料內容對應 design_handoff_quote_app/data.jsx 的 SAMPLE_QUOTES / SAMPLE_CLIENTS。
///
/// 用法：
///   #Preview {
///       HomeScreen()
///           .modelContainer(PreviewData.container)
///           .environment(PreviewData.settings)
///   }
enum PreviewData {

    // MARK: - AppSettings

    static let settings: AppSettings = {
        let s = AppSettings()
        s.masterName = "陳師傅"
        s.isPro = false
        return s
    }()

    static let settingsPro: AppSettings = {
        let s = AppSettings()
        s.masterName = "陳師傅"
        s.isPro = true
        return s
    }()

    // MARK: - ModelContainer

    /// 含範例資料的 in-memory container，適合大多數畫面的 preview。
    @MainActor
    static let container: ModelContainer = {
        let schema = Schema([Quote.self, QuoteItem.self, Client.self, CustomItem.self, PDFTemplate.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let ctx = container.mainContext

        // 客戶
        let clients = makeSampleClients()
        clients.forEach { ctx.insert($0) }

        // 報價單
        makeSampleQuotes().forEach { ctx.insert($0) }

        // 預設 PDF 模板
        let template = PDFTemplate()
        template.businessName = "大發工程行"
        template.phone = "02-2345-6789"
        ctx.insert(template)

        return container
    }()

    // MARK: - 範例資料

    @MainActor
    static func makeSampleClients() -> [Client] {
        [
            { let c = Client(name: "王先生",  phone: "0912-345-678", address: "台北市信義區松仁路 100 號",      notes: "新案場主，喜歡簡潔風"); return c }(),
            { let c = Client(name: "林太太",  phone: "0922-111-222", email: "lin@example.com", address: "新北市板橋區文化路二段 150 號", notes: "老客戶，付款乾脆"); return c }(),
            { let c = Client(name: "張先生",  phone: "0933-456-789", address: "台北市大安區仁愛路四段 27 號",   notes: "介紹過 3 位朋友"); return c }(),
            { let c = Client(name: "李小姐",  phone: "0955-789-123", address: "新北市中和區中山路一段 88 號"); return c }(),
            { let c = Client(name: "黃先生",  phone: "0966-234-567", address: "桃園市中壢區中央西路 33 號",    notes: "林老闆介紹"); return c }(),
            { let c = Client(name: "陳老闆",  phone: "0988-098-123", email: "chen@biz.tw", address: "台北市內湖區瑞光路 188 號", notes: "辦公室客戶，每年 2~3 案"); return c }(),
        ]
    }

    @MainActor
    static func makeSampleQuotes() -> [Quote] {
        // total 直接用設計稿的好看數字，不從 items 算（設計稿的 items 是示意性的，
        // 加起來不會剛好等於 total，這在 preview 不重要，重要的是視覺評估）。
        let data: [(client: String, location: String, dateStr: String, status: QuoteStatus, folder: String?, total: Int, items: [(String, String, Double, Int)])] = [
            ("王先生", "台北市信義區", "2026-05-15", .ongoing, "2026",  285_000, [("拆除磁磚", "坪", 10, 1800), ("冷氣排水管", "式", 1, 3500), ("油漆批土", "坪", 25, 850)]),
            ("林太太", "新北市板橋區", "2026-05-10", .paid,    "2026",  156_000, [("水電配管", "式", 1, 35000), ("新增插座", "個", 8, 1200)]),
            ("張先生", "台北市大安區", "2026-04-28", .ongoing, "老客戶", 420_000, [("木作天花板", "坪", 30, 3200), ("系統櫃", "尺", 25, 4500)]),
            ("李小姐", "新北市中和區", "2026-04-15", .done,    "2026",   98_000, [("貼磁磚", "坪", 8, 2800), ("防水工程", "坪", 8, 1800)]),
            ("黃先生", "桃園市中壢區", "2026-03-20", .draft,   nil,     215_000, [("冷氣排水管", "式", 2, 3500), ("全室油漆", "坪", 35, 1200)]),
            ("陳老闆", "台北市內湖區", "2026-02-12", .paid,    "老客戶", 380_000, [("木作天花板", "坪", 25, 3200), ("系統櫃", "尺", 18, 4500), ("全室油漆", "坪", 18, 1200)]),
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return data.map { d in
            let q = Quote(
                clientName: d.client,
                location:   d.location,
                date:       formatter.date(from: d.dateStr) ?? .now,
                folder:     d.folder,
                status:     d.status
            )
            d.items.forEach { name, unit, qty, price in
                q.items.append(QuoteItem(name: name, unit: unit, qty: qty, price: price))
            }
            q.total = d.total
            return q
        }
    }
}
