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
    // 屬性層級預設值不可省：這是「後來才加」的欄位，SwiftData 需要它才能對舊 store 做輕量遷移，
    // 否則 ModelContainer 會建立失敗、退回記憶體資料庫（資料每次啟動都不見）。
    var paymentInfo: String = ""   // 收款資訊（匯款帳號 / LINE Pay / 現金…），一行一項；空 → 請款單不顯示
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
        self.paymentInfo = ""
        self.validDays = 30
        self.showSignatureLine = false
        self.brandColor = "#C9522A"
        self.fontStyle = "sans"
    }
}
