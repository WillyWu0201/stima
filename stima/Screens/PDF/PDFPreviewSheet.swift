import SwiftUI
import SwiftData

/// 畫面 14 · PDF 預覽
/// 從 Detail / PDFTemplate 的「預覽 PDF」按鈕召喚的 page-sheet。
/// 內含 A4 layout 預覽。免費版會疊浮水印。
struct PDFPreviewSheet: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Query private var templates: [PDFTemplate]
    @Query private var allClients: [Client]

    private var template: PDFTemplate? { templates.first }
    private var client: Client? { allClients.first { $0.name == quote.clientName } }
    private var brandColor: Color { Self.parseHex(template?.brandColor ?? "#C9522A") }

    private var subtotal: Int { quote.items.reduce(0) { $0 + $1.subtotal } }
    private var tax: Int { Int((Double(subtotal) * 0.05).rounded()) }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                paper
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 14)
            }
        }
        .background(Color(red: 0.898, green: 0.886, blue: 0.863))  // 桌面暖灰
        .safeAreaInset(edge: .bottom) {
            footerActions
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("PDF 預覽")
                .font(AppFont.sans(17, weight: .bold))
                .foregroundStyle(Color.ink)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.inkSoft)
                    .frame(width: 32, height: 32)
                    .background(Color.bgSoft, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - A4 paper

    private var paper: some View {
        VStack(alignment: .leading, spacing: 0) {
            letterhead
            recipientBlock
                .padding(.top, 14)
                .padding(.bottom, 12)
            itemsTable
                .padding(.bottom, 16)
            totalsBlock
                .padding(.bottom, 14)
            paymentTerms
                .padding(.bottom, 26)
            signatures
        }
        .padding(24)
        .background(Color.white,
                    in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
        .overlay(watermark)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    // 表頭：logo + 商號 / 報價單編號 + 標題
    private var letterhead: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // logo placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color(white: 0.7),
                                      style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    Text("LOGO")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(white: 0.55))
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(businessName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(brandColor)
                    if !slogan.isEmpty {
                        Text(slogan)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    if !contactLine.isEmpty {
                        Text(contactLine)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(Color(white: 0.5))
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("報價單 #\(quoteIDLast4)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(Color(white: 0.55))
                    Text("報 價 單")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .kerning(2)
                    Text("有效期限 \(template?.validDays ?? 30) 天")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(white: 0.55))
                }
            }
            .padding(.bottom, 12)

            // 品牌色底線
            brandColor.frame(height: 3)
        }
    }

    private var recipientBlock: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("致 / TO")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.55))
                    .kerning(1)
                Text(quote.clientName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.85))
                if !quote.location.isEmpty {
                    Text(quote.location)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(white: 0.45))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("日期 / DATE")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.55))
                    .kerning(1)
                Text(Self.dateFormatter.string(from: quote.date))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(Color.black.opacity(0.85))
            }
        }
    }

    // MARK: - Items table

    private var itemsTable: some View {
        VStack(spacing: 0) {
            // 表頭
            HStack(spacing: 0) {
                col("項目",  width: nil,     align: .leading,  flexible: true)
                col("單位",  width: 36,      align: .center)
                col("數量",  width: 42,      align: .trailing)
                col("單價",  width: 56,      align: .trailing)
                col("小計",  width: 70,      align: .trailing)
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundStyle(Color(white: 0.45))
            .kerning(1.2)
            .padding(.vertical, 6)
            .background(
                VStack(spacing: 0) {
                    Color(white: 0.85).frame(height: 1)
                    Spacer()
                    Color(white: 0.85).frame(height: 1)
                }
            )

            ForEach(quote.items.indices, id: \.self) { i in
                let item = quote.items[i]
                HStack(spacing: 0) {
                    col(item.name,                          width: nil, align: .leading,  flexible: true)
                    col(item.unit,                          width: 36,  align: .center)
                    col(String(Int(item.qty)),              width: 42,  align: .trailing, mono: true)
                    col("$\(item.price.formatted())",       width: 56,  align: .trailing, mono: true)
                    col("$\(item.subtotal.formatted())",    width: 70,  align: .trailing, mono: true)
                }
                .font(.system(size: 11))
                .foregroundStyle(Color.black.opacity(0.8))
                .padding(.vertical, 7)
                if i < quote.items.count - 1 {
                    // dotted divider
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(height: 1)
                        .mask(
                            HStack(spacing: 2) {
                                ForEach(0..<80, id: \.self) { _ in
                                    Rectangle().fill(.black).frame(width: 1)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        )
                }
            }
        }
    }

    @ViewBuilder
    private func col(_ text: String, width: CGFloat?, align: Alignment,
                     flexible: Bool = false, mono: Bool = false) -> some View {
        let view = Text(text)
            .font(mono ? .system(size: 11, design: .monospaced) : .system(size: 11))
            .multilineTextAlignment(textAlign(align))
        if let width {
            view.frame(width: width, alignment: align)
        } else if flexible {
            view.frame(maxWidth: .infinity, alignment: align)
        } else {
            view
        }
    }

    private func textAlign(_ a: Alignment) -> TextAlignment {
        switch a {
        case .leading:  return .leading
        case .trailing: return .trailing
        default:        return .center
        }
    }

    // MARK: - Totals

    private var totalsBlock: some View {
        VStack(alignment: .trailing, spacing: 6) {
            totalsRow("小計", "$\(subtotal.formatted())")
            totalsRow("稅金 5%", "$\(tax.formatted())")
            brandColor.frame(height: 2).padding(.top, 2)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("總計  NT$")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))
                Text(quote.total.formatted())
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(brandColor)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func totalsRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 14) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color(white: 0.45))
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Color.black.opacity(0.7))
                .frame(minWidth: 76, alignment: .trailing)
        }
    }

    // MARK: - Payment terms

    private var paymentTerms: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("付款條件")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.8))
            Text(template?.paymentTerms.isEmpty == false
                 ? template!.paymentTerms
                 : "簽約付 30%、完工驗收 60%、保固期滿 10%")
                .font(.system(size: 10))
                .foregroundStyle(Color(white: 0.45))
                .lineSpacing(2)
        }
    }

    // MARK: - Signatures

    private var signatures: some View {
        HStack(alignment: .bottom, spacing: 24) {
            signatureLine(label: "甲方（客戶）簽名")
            signatureLine(label: "乙方（廠商）簽章")
        }
    }

    private func signatureLine(label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Rectangle().fill(Color(white: 0.4)).frame(height: 1)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(Color(white: 0.5))
        }
    }

    // MARK: - Watermark（免費版）

    @ViewBuilder
    private var watermark: some View {
        if !settings.isPro {
            Text("師傅號 · 免費版")
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(Color.ink.opacity(0.06))
                .rotationEffect(.degrees(-30))
                .allowsHitTesting(false)
        }
    }

    // MARK: - Footer

    private var footerActions: some View {
        HStack(spacing: 10) {
            ShareSecondaryButton(
                title: "分享",
                message: ShareMessage.forQuote(quote, masterName: settings.masterName)
            )
            PrimaryButton("儲存 PDF", systemImage: "doc.text") {
                // TODO: PDFKit 真實 render + 寫檔
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color(red: 0.898, green: 0.886, blue: 0.863))
        .overlay(alignment: .top) {
            Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
        }
    }

    // MARK: - Helpers

    private var businessName: String {
        if let t = template, !t.businessName.isEmpty { return t.businessName }
        let n = settings.masterName
        return n.isEmpty ? "陳師傅" : n
    }

    private var slogan: String { template?.slogan ?? "" }

    private var contactLine: String {
        var bits: [String] = []
        if let t = template {
            if !t.phone.isEmpty   { bits.append(t.phone) }
            if !t.address.isEmpty { bits.append(t.address) }
        }
        return bits.joined(separator: " · ")
    }

    private var quoteIDLast4: String {
        String(quote.id.uuidString.prefix(4))
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func parseHex(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt(s, radix: 16) else {
            return Color.accent
        }
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8)  & 0xFF) / 255
        let b = Double(v         & 0xFF) / 255
        return Color(red: r, green: g, blue: b)
    }
}

#Preview("免費版（有浮水印）") {
    let quote = PreviewData.makeSampleQuotes()[0]
    return Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PDFPreviewSheet(quote: quote)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .environment(PreviewData.settings)
        .modelContainer(PreviewData.container)
}

#Preview("PRO（無浮水印）") {
    let quote = PreviewData.makeSampleQuotes()[0]
    return Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PDFPreviewSheet(quote: quote)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .environment(PreviewData.settingsPro)
        .modelContainer(PreviewData.container)
}
