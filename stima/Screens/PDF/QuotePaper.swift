import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A4 紙張內容（letterhead + 致 / 項目 / 總計 / 付款條件 / 簽名）。
/// 不含 shadow / clipShape — 那些是 PDFPreviewSheet 預覽時的 chrome，PDF 渲染時不需要。
/// 寬度建議：preview 時用螢幕寬，匯出 PDF 時用 595pt (A4 @ 72dpi)。
struct QuotePaper: View {
    let quote: Quote
    let template: PDFTemplate?
    let masterName: String
    let watermarked: Bool
    var currencySymbol: String = "$"

    private var subtotal: Int { quote.items.reduce(0) { $0 + $1.subtotal } }
    /// 從已存的 total 反推稅金，與畫面顯示一致。
    private var tax: Int { max(0, quote.total - subtotal) }
    private var taxPercent: Int {
        subtotal > 0 ? Int((Double(tax) / Double(subtotal) * 100).rounded()) : 0
    }
    private var brandColor: Color { Self.parseHex(template?.brandColor ?? "#C9522A") }
    private var quoteIDLast4: String { String(quote.id.uuidString.prefix(4)) }

    private var businessName: String {
        if let t = template, !t.businessName.isEmpty { return t.businessName }
        // 最後 fallback 用 App 名稱，而非寫死的範例人名（抬頭理論上一定有值，這只是防呆）。
        return masterName.isEmpty ? "Stima" : masterName
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            letterhead
            recipientBlock.padding(.top, 14).padding(.bottom, 12)
            itemsTable.padding(.bottom, 16)
            totalsBlock.padding(.bottom, 14)
            paymentTerms.padding(.bottom, 26)
            signatures
        }
        .padding(24)
        .background(Color.white)
        .overlay(watermark)
    }

    // MARK: - Logo

    /// 只有真的上傳了 logo 才回傳圖；沒設就 nil → PDF 不畫 logo 區（不留虛線空框）。
    private var logoImage: UIImage? {
        guard let data = template?.logoData else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Letterhead

    private var letterhead: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                if let logo = logoImage {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .padding(2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(businessName)
                        .font(bodyFont(17, weight: .bold))
                        .foregroundStyle(brandColor)
                    if !slogan.isEmpty {
                        Text(slogan)
                            .font(bodyFont(11))
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
                        .font(bodyFont(17, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .kerning(2)
                    Text("有效期限 \(template?.validDays ?? 30) 天")
                        .font(.system(size: 9))
                        .foregroundStyle(Color(white: 0.55))
                }
            }
            .padding(.bottom, 12)

            brandColor.frame(height: 3)
        }
    }

    // MARK: - Recipient

    private var recipientBlock: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("致 / TO")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.55))
                    .kerning(1)
                Text(quote.clientName)
                    .font(bodyFont(15, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.85))
                if !quote.location.isEmpty {
                    Text(quote.location)
                        .font(bodyFont(10))
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
            HStack(spacing: 0) {
                col("項目",  width: nil, align: .leading,  flexible: true)
                col("單位",  width: 36,  align: .center)
                col("數量",  width: 42,  align: .trailing)
                col("單價",  width: 56,  align: .trailing)
                col("小計",  width: 70,  align: .trailing)
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
                    col("\(currencySymbol)\(item.price.formatted())",    width: 56,  align: .trailing, mono: true)
                    col("\(currencySymbol)\(item.subtotal.formatted())", width: 70,  align: .trailing, mono: true)
                }
                .font(.system(size: 11))
                .foregroundStyle(Color.black.opacity(0.8))
                .padding(.vertical, 7)
                if i < quote.items.count - 1 {
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
            .font(mono ? .system(size: 11, design: .monospaced) : bodyFont(11))
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
            totalsRow("小計", "\(currencySymbol)\(subtotal.formatted())")
            totalsRow("稅金 \(taxPercent)%", "\(currencySymbol)\(tax.formatted())")
            brandColor.frame(height: 2).padding(.top, 2)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("總計  \(currencySymbol)")
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
                .font(bodyFont(11, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.8))
            Text(template?.paymentTerms.isEmpty == false
                 ? template!.paymentTerms
                 : "簽約付 30%、完工驗收 60%、保固期滿 10%")
                .font(bodyFont(10))
                .foregroundStyle(Color(white: 0.45))
                .lineSpacing(2)
        }
    }

    // MARK: - Signatures

    private var signatures: some View {
        HStack(alignment: .bottom, spacing: 24) {
            signatureLine(label: "甲方（客戶）簽名")
            signatureLine(label: "乙方（廠商）簽章")
                .overlay(alignment: .trailing) {
                    stampOverlay
                        .offset(x: 4, y: -18)
                }
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

    @ViewBuilder
    private var stampOverlay: some View {
        if let data = template?.stampData, let img = UIImage(data: data) {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: 54, height: 54)
                .opacity(0.85)
        }
    }

    // MARK: - Watermark

    @ViewBuilder
    private var watermark: some View {
        if watermarked {
            Text(TierConfig.watermarkText)
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(Color.black.opacity(TierConfig.watermarkOpacity))
                .rotationEffect(.degrees(TierConfig.watermarkAngle))
                .allowsHitTesting(false)
        }
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// 依模板選的字體回傳「內文」字型；數字/等寬欄不受影響（仍維持 monospaced）。
    private func bodyFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch template?.fontStyle {
        case "明體": return .system(size: size, weight: weight, design: .serif)
        case "楷體": return .custom("Kaiti TC", size: size).weight(weight)
        default:     return .system(size: size, weight: weight)   // 黑體 / 預設（sans）
        }
    }

    static func parseHex(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt(s, radix: 16) else { return Color.accent }
        return Color(red: Double((v >> 16) & 0xFF) / 255,
                     green: Double((v >> 8)  & 0xFF) / 255,
                     blue: Double(v         & 0xFF) / 255)
    }
}
