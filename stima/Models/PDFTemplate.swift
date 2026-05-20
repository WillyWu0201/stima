import Foundation
import SwiftData

@Model
final class PDFTemplate {
    var businessName: String
    var slogan: String
    var phone: String
    var email: String
    var address: String
    var paymentTerms: String
    var validDays: Int          // 7 / 14 / 30 / 60 / 90
    var showSignatureLine: Bool
    var brandColor: String      // hex string, default "#C9522A"
    var fontStyle: String       // "sans" / "serif" / "kaiti"
    var logoData: Data?
    var stampData: Data?

    init() {
        self.businessName = ""
        self.slogan = ""
        self.phone = ""
        self.email = ""
        self.address = ""
        self.paymentTerms = ""
        self.validDays = 30
        self.showSignatureLine = false
        self.brandColor = "#C9522A"
        self.fontStyle = "sans"
    }
}
