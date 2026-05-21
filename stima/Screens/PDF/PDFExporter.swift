import SwiftUI
import CoreGraphics
import UniformTypeIdentifiers

/// 把 QuotePaper 渲染成 A4 PDF 寫進 temporary 目錄，回傳檔案 URL 供 ShareLink 用。
@MainActor
enum PDFExporter {

    /// A4 標準 @ 72 dpi：595.275 × 841.890，取整作為 page mediaBox。
    /// 不管內容多少高度，輸出都固定 A4 整頁；內容少時下面留白、超出時被裁切。
    private static let a4Width: CGFloat = 595
    private static let a4Height: CGFloat = 842

    static func renderQuote(
        _ quote: Quote,
        template: PDFTemplate?,
        masterName: String,
        watermarked: Bool
    ) -> URL? {
        let paper = QuotePaper(
            quote:       quote,
            template:    template,
            masterName:  masterName,
            watermarked: watermarked
        )
        .frame(width: a4Width, alignment: .top)
        .background(Color.white)

        let renderer = ImageRenderer(content: paper)
        // 寬度 fix A4，高度給足 A4 讓 view 撐到頂部
        renderer.proposedSize = ProposedViewSize(width: a4Width, height: a4Height)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename(for: quote))

        var success = false
        renderer.render { contentSize, drawIntoContext in
            // mediaBox 固定 A4 整頁
            var box = CGRect(x: 0, y: 0, width: a4Width, height: a4Height)
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let pdfCtx = CGContext(consumer: consumer, mediaBox: &box, nil)
            else { return }
            pdfCtx.beginPDFPage(nil)
            // 內容靠上對齊頁面頂部：把座標系平移到 view 應該畫的位置
            // ImageRenderer 預設由左上 (0, 0) 畫，PDF 座標系原點在左下，
            // 所以要 translate 讓 view 出現在頁面上半部
            let topOffsetY = a4Height - contentSize.height
            pdfCtx.translateBy(x: 0, y: max(0, topOffsetY))
            drawIntoContext(pdfCtx)
            pdfCtx.endPDFPage()
            pdfCtx.closePDF()
            success = true
        }
        return success ? url : nil
    }

    private static func filename(for quote: Quote) -> String {
        let safe = sanitize(quote.clientName)
        let date = dateFormatter.string(from: quote.date)
        return "報價單-\(safe)-\(date).pdf"
    }

    private static func sanitize(_ s: String) -> String {
        let bad: Set<Character> = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]
        return String(s.map { bad.contains($0) ? "_" : $0 })
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
}
