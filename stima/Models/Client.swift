import Foundation
import SwiftData

@Model
final class Client {
    var id: UUID
    var name: String
    var phone: String
    var email: String
    var address: String
    var notes: String
    var lastContact: Date

    init(
        name: String,
        phone: String = "",
        email: String = "",
        address: String = "",
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.notes = notes
        self.lastContact = .now
    }
}
