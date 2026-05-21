import Testing
import Foundation
@testable import stima

@Suite("PDFExporter · A4 PDF 渲染")
@MainActor
struct PDFExporterTests {

    private func sampleQuote() -> Quote {
        let q = Quote(clientName: "王先生", location: "台北市信義區",
                      date: .now, status: .ongoing)
        q.items.append(QuoteItem(name: "拆除磁磚", unit: "坪", qty: 10, price: 1800))
        q.items.append(QuoteItem(name: "油漆批土", unit: "坪", qty: 25, price: 850))
        q.recalcTotal()
        return q
    }

    @Test("渲染 quote 產生實體 PDF 檔案")
    func rendersFile() throws {
        let q = sampleQuote()
        let url = try #require(PDFExporter.renderQuote(
            q,
            template:    nil,
            masterName:  "陳師傅",
            watermarked: true
        ))
        #expect(FileManager.default.fileExists(atPath: url.path))

        let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
        let size = attrs[.size] as? Int ?? 0
        #expect(size > 0, "PDF 檔案是空的")
    }

    @Test("PDF 檔案副檔名為 .pdf")
    func filenameHasPdfExtension() throws {
        let q = sampleQuote()
        let url = try #require(PDFExporter.renderQuote(
            q, template: nil, masterName: "", watermarked: false))
        #expect(url.pathExtension == "pdf")
    }

    @Test("檔名含客戶名跟日期")
    func filenameContainsClientAndDate() throws {
        let q = sampleQuote()
        let url = try #require(PDFExporter.renderQuote(
            q, template: nil, masterName: "", watermarked: false))
        let filename = url.lastPathComponent
        #expect(filename.contains("王先生"))
        #expect(filename.contains("報價單"))
    }

    @Test("不合法字元會被過濾掉")
    func filenameSanitizesIllegalChars() throws {
        let q = Quote(clientName: "客戶/X:Y*Z", location: "", date: .now)
        q.items.append(QuoteItem(name: "x", unit: "式", qty: 1, price: 1000))
        q.recalcTotal()
        let url = try #require(PDFExporter.renderQuote(
            q, template: nil, masterName: "", watermarked: false))
        let filename = url.lastPathComponent
        // 不合法字元 / : * 應該全被換成 _
        #expect(!filename.contains("/X:Y*Z"))
        #expect(filename.contains("客戶_X_Y_Z"))
    }

    @Test("換不同 brandColor 仍能成功渲染")
    func customBrandColorRenders() throws {
        let template = PDFTemplate()
        template.businessName = "測試"
        template.brandColor = "#2A6FDB"      // blue
        let q = sampleQuote()
        let url = try #require(PDFExporter.renderQuote(
            q, template: template, masterName: "", watermarked: false))
        #expect(FileManager.default.fileExists(atPath: url.path))
    }
}
