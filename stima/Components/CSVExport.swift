import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// 包一層讓 URL 能用在 `.sheet(item:)`。
struct ExportableFile: Identifiable {
    let id = UUID()
    let url: URL
}

/// 把所有報價單匯出成 CSV 檔（UTF-8 + BOM，Excel 開中文不亂碼）。
enum QuoteCSV {
    static func export(_ quotes: [Quote]) -> ExportableFile? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        var rows = ["日期,客戶,地點,狀態,項目數,總計"]
        for q in quotes.sorted(by: { $0.date > $1.date }) {
            let fields = [
                df.string(from: q.date),
                q.clientName,
                q.location,
                q.quoteStatus.label,
                String(q.items.count),
                String(q.total),
            ].map(escape)
            rows.append(fields.joined(separator: ","))
        }

        let csv = "\u{FEFF}" + rows.joined(separator: "\n")
        let name = "Stima報價單_\(df.string(from: .now)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return ExportableFile(url: url)
        } catch {
            return nil
        }
    }

    private nonisolated static func escape(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else {
            return field
        }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }
}

#if canImport(UIKit)
/// 系統分享面板（UIActivityViewController）的 SwiftUI 包裝，給「匯出檔案」用。
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
