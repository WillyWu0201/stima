import Foundation

/// 新增報價單流程跨畫面共享的編輯狀態。
/// 完成出單時才轉成 Quote + QuoteItem 寫進 SwiftData。
@Observable
final class NewQuoteDraft {
    var clientName: String = ""
    var location: String = ""
    var date: Date = .now
    var folder: String? = nil
    var items: [Item] = []

    struct Item: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var unit: String
        var qty: Double
        var price: Int
        var cost: Int = 0

        var subtotal: Int { Int(qty) * price }
    }

    var subtotal: Int {
        items.reduce(0) { $0 + $1.subtotal }
    }

    /// `ratePercent` 是百分比（例：5 代表 5%），與 `AppSettings.taxRate` 同單位。
    func tax(ratePercent: Double = 5) -> Int {
        Int((Double(subtotal) * ratePercent / 100).rounded())
    }

    func total(ratePercent: Double = 5) -> Int {
        subtotal + tax(ratePercent: ratePercent)
    }
}

// MARK: - 編輯既有報價單（draft ↔ Quote 映射）

extension NewQuoteDraft {
    /// 從既有 Quote 建出可編輯的 draft（保留原始日期與 folder，含各項目成本）。
    static func from(_ quote: Quote) -> NewQuoteDraft {
        let d = NewQuoteDraft()
        d.clientName = quote.clientName
        d.location   = quote.location
        d.date       = quote.date
        d.folder     = quote.folder
        d.items      = quote.items.map {
            Item(name: $0.name, unit: $0.unit, qty: $0.qty, price: $0.price, cost: $0.cost)
        }
        return d
    }

    /// 把 draft 內容寫回既有 quote（編輯儲存）：重建 items、重算 total。
    /// 保留 quote 的 id / status / dueDate 不變（只有內容被更新）。
    func apply(to quote: Quote, taxRatePercent: Double = 5) {
        quote.clientName = clientName.isEmpty ? "未命名客戶" : clientName
        quote.location   = location
        quote.date       = date
        quote.folder     = folder
        quote.items      = items.map {
            QuoteItem(name: $0.name, unit: $0.unit, qty: $0.qty, price: $0.price, cost: $0.cost)
        }
        quote.recalcTotal(taxRatePercent: taxRatePercent)
    }
}
