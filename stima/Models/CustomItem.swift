import Foundation
import SwiftData

@Model
final class CustomItem {
    var name: String
    var unit: String
    var price: Int
    var category: String

    init(name: String, unit: String, price: Int, category: String) {
        self.name = name
        self.unit = unit
        self.price = price
        self.category = category
    }
}
