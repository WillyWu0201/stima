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
