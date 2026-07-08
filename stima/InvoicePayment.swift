import Foundation

/// 請款單「付款方式」的資料處理。
/// 使用者在 PDF 模板設定裡填的收款資訊是多行純文字，這裡拆成非空行；
/// 沒填就回空陣列，請款單據此隱藏整張卡（不再顯示寫死的假帳號）。
enum InvoicePayment {
    static func lines(from raw: String) -> [String] {
        raw.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
