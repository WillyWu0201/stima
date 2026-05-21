import SwiftUI
import CoreGraphics
import UniformTypeIdentifiers

/// 把 QuotePaper 渲染成 A4 PDF 寫進 temporary 目錄，回傳檔案 URL 供 ShareLink 用。
@MainActor
enum PDFExporter {

    /// A4 width @ 72 dpi = 595.275 → 取整 595。高度由 view 自己撐開。
    private static let a4Width: CGFloat = 595

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
        .frame(width: a4Width)
        .background(Color.white)

        let renderer = ImageRenderer(content: paper)
        renderer.proposedSize = ProposedViewSize(width: a4Width, height: nil)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename(for: quote))

        var success = false
        renderer.render { size, drawIntoContext in
            var box = CGRect(origin: .zero, size: size)
            guard let consumer = CGDataConsumer(url: url as CFURL),
                  let pdfCtx = CGContext(consumer: consumer, mediaBox: &box, nil)
            else { return }
            pdfCtx.beginPDFPage(nil)
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
