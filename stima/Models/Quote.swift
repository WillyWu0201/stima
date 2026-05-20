import Foundation
import SwiftData

@Model
final class Quote {
    var id: UUID
    var clientName: String
    var location: String
    var date: Date
    var folder: String?
    var status: String          // QuoteStatus.rawValue
    var dueDate: Date?
    var invoiceID: UUID?        // linked invoice once 轉請款單

    @Relationship(deleteRule: .cascade)
    var items: [QuoteItem]

    // Computed — stored for query/sort performance
    var total: Int

    init(
        clientName: String = "",
        location: String = "",
        date: Date = .now,
        folder: String? = nil,
        status: QuoteStatus = .draft
    ) {
        self.id = UUID()
        self.clientName = clientName
        self.location = location
        self.date = date
        self.folder = folder
        self.status = status.rawValue
        self.items = []
        self.total = 0
    }

    var quoteStatus: QuoteStatus {
        QuoteStatus(rawValue: status) ?? .draft
    }

    func recalcTotal(taxRate: Double = 0.05) {
        let subtotal = items.reduce(0) { $0 + $1.subtotal }
        total = subtotal + Int((Double(subtotal) * taxRate).rounded())
    }
}

@Model
final class QuoteItem {
    var name: String
    var unit: String
    var qty: Double
    var price: Int

    init(name: String, unit: String, qty: Double, price: Int) {
        self.name = name
        self.unit = unit
        self.qty = qty
        self.price = price
    }

    var subtotal: Int { Int(qty) * price }
}
