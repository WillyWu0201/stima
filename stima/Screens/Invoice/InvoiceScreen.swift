import SwiftUI
import SwiftData

/// 畫面 15 · 請款單
/// 從 DetailScreen 的「轉請款單」推進（僅 ongoing/done 顯示按鈕）。
/// 共用同一個 Quote 物件，差別是這頁顯示 dueDate + 請款金額標籤 + 付款方式 +「標記已收款」。
struct InvoiceScreen: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings

    private var subtotal: Int { quote.items.reduce(0) { $0 + $1.subtotal } }
    /// 從已存的 total 反推稅金，與報價單明細一致。
    private var tax: Int { max(0, quote.total - subtotal) }
    private var taxPercent: Int {
        subtotal > 0 ? Int((Double(tax) / Double(subtotal) * 100).rounded()) : 0
    }
    private var invoiceID: String { "INV-\(String(quote.id.uuidString.prefix(4)))" }
    private var quoteIDLast4: String { String(quote.id.uuidString.prefix(4)) }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: quote.clientName,
                subtitle: "請款單 · \(invoiceID)",
                accent: true,
                onBack: { dismiss() }
            ) {
                statusPill
            }

            ScrollView {
                VStack(spacing: Spacing.cardGap) {
                    dueDateCard
                    factsCard
                    itemsCard
                    totalsCard
                    paymentMethodsCard
                    actionRow
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 第一次進來如果 dueDate 還沒設，預設為今天 + 30 天
            if quote.dueDate == nil {
                quote.dueDate = Calendar.current.date(byAdding: .day, value: 30, to: .now)
            }
        }
    }

    // MARK: - Header trailing badge

    private var statusPill: some View {
        Text("請款中")
            .font(AppFont.mono(11, weight: .bold))
            .foregroundStyle(Color.accent2)
            .kerning(1.2)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.accent.opacity(0.25), in: Capsule())
    }

    // MARK: - Due date

    private var dueDateCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "clock")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accent)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text("付款到期日：\(dueDateString)")
                    .font(AppFont.sans(14, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text("從報價單 #\(quoteIDLast4) 轉成請款單 · 工程已完工")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer()
        }
        .padding(Spacing.card)
        .background(Color.surfaceAlt,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.accent)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.appBorder, lineWidth: 1)
        )
    }

    // MARK: - Facts

    private var factsCard: some View {
        AppCard {
            HStack(alignment: .top, spacing: 16) {
                fact(symbol: "mappin", label: "工程地點", value: quote.location)
                    .frame(maxWidth: .infinity, alignment: .leading)
                fact(symbol: "calendar", label: "完工日", value: completionDateString)
            }
        }
    }

    private func fact(symbol: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol).font(.system(size: 11))
                Text(label)
            }
            .font(AppFont.sans(11))
            .foregroundStyle(Color.inkSoft)
            Text(value.isEmpty ? "—" : value)
                .font(AppFont.sans(14, weight: .medium))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Items

    private var itemsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("請款明細")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .kerning(1.4)
                    .textCase(.uppercase)
                    .padding(.bottom, 4)

                ForEach(quote.items.indices, id: \.self) { i in
                    itemRow(quote.items[i])
                        .padding(.vertical, 8)
                    if i < quote.items.count - 1 {
                        AppDivider()
                    }
                }
            }
        }
    }

    private func itemRow(_ item: QuoteItem) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(AppFont.sans(14, weight: .semibold))
                    .foregroundStyle(Color.ink)
                Text("\(Int(item.qty)) \(item.unit) × $\(item.price.formatted())")
                    .font(AppFont.mono(12))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer()
            Money(item.subtotal, size: 15, color: .ink)
        }
    }

    // MARK: - Totals（請款金額）

    private var totalsCard: some View {
        AppCard(accent: true) {
            VStack(spacing: 6) {
                summaryRow("小計", value: subtotal)
                summaryRow("稅金 \(taxPercent)%", value: tax)
                Rectangle()
                    .fill(Color.accentSurfaceInk.opacity(0.2))
                    .frame(height: 1)
                    .padding(.vertical, 4)
                HStack {
                    Text("請款金額")
                        .font(AppFont.sans(14, weight: .bold))
                        .foregroundStyle(Color.accentSurfaceInk)
                    Spacer()
                    Money(quote.total, size: 26, color: .accent2)
                }
            }
        }
    }

    private func summaryRow(_ label: String, value: Int) -> some View {
        HStack {
            Text(label).font(AppFont.sans(13))
            Spacer()
            Text("$\(value.formatted())").font(AppFont.mono(13))
        }
        .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
    }

    // MARK: - 付款方式

    private var paymentMethodsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("付款方式")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .kerning(1.4)
                    .textCase(.uppercase)

                methodRow("匯款：玉山銀行 (808) 123-4567-890-1")
                methodRow("LINE Pay / 街口：掃描下方 QR Code")
                methodRow("現金：請聯絡 0912-345-678 約時間")
            }
        }
    }

    private func methodRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("·")
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkSoft)
            Text(text)
                .font(AppFont.sans(13))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Actions

    private var actionRow: some View {
        HStack(spacing: 10) {
            SecondaryButton("標記已收款", systemImage: "checkmark") {
                markAsPaid()
            }
            .disabled(quote.quoteStatus == .paid)
            ShareSecondaryButton(
                title: "傳給客戶",
                message: ShareMessage.forInvoice(quote, masterName: settings.masterName)
            )
        }
        .padding(.top, 4)
    }

    private func markAsPaid() {
        quote.status = QuoteStatus.paid.rawValue
        dismiss()
    }

    // MARK: - Date helpers

    private var dueDateString: String {
        if let due = quote.dueDate {
            return Self.dateFormatter.string(from: due)
        }
        return "—"
    }

    private var completionDateString: String {
        // 沒有專屬完工日 field，先用 quote.date 當代表
        Self.dateFormatter.string(from: quote.date)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview {
    let quote = PreviewData.makeSampleQuotes()[0]
    return NavigationStack {
        InvoiceScreen(quote: quote)
    }
    .modelContainer(PreviewData.container)
}
