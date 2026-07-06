import Foundation

/// 生成分享給客戶看的文字內容（LINE / 簡訊 / Email 都會用同一份）。
/// 之後 PDF render 接上後，分享 payload 可加上 PDF file 附件。
enum ShareMessage {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func forQuote(_ q: Quote, masterName: String, currencySymbol: String = "$") -> String {
        let date = formatter.string(from: q.date)
        let total = "\(currencySymbol) \(q.total.formatted())"
        let signOff = masterName.isEmpty ? "" : "\n\(masterName)"
        var lines: [String] = []
        lines.append("【報價單】\(q.clientName)")
        lines.append("日期：\(date)")
        if !q.location.isEmpty {
            lines.append("地點：\(q.location)")
        }
        lines.append("項目共 \(q.items.count) 筆")
        lines.append("總金額：\(total)")
        if !signOff.isEmpty {
            lines.append(signOff)
        }
        return lines.joined(separator: "\n")
    }

    static func forInvoice(_ q: Quote, masterName: String, currencySymbol: String = "$") -> String {
        let total = "\(currencySymbol) \(q.total.formatted())"
        let due = q.dueDate.map { formatter.string(from: $0) } ?? "—"
        let signOff = masterName.isEmpty ? "" : "\n\(masterName)"
        var lines: [String] = []
        lines.append("【請款單】\(q.clientName)")
        lines.append("請款金額：\(total)")
        lines.append("付款到期日：\(due)")
        if !q.location.isEmpty {
            lines.append("工程地點：\(q.location)")
        }
        if !signOff.isEmpty {
            lines.append(signOff)
        }
        return lines.joined(separator: "\n")
    }
}
