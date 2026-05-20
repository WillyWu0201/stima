import SwiftUI
import SwiftData

/// 畫面 09 · 報價單詳情
/// 從 Home 推進，顯示完整內容並提供主要操作（傳給客戶 / 預覽 PDF / 複製 / 轉請款單）。
struct DetailScreen: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Query private var allClients: [Client]

    private var matchingClient: Client? {
        allClients.first { $0.name == quote.clientName }
    }

    private var subtotal: Int {
        quote.items.reduce(0) { $0 + $1.subtotal }
    }

    private var tax: Int {
        Int((Double(subtotal) * 0.05).rounded())
    }

    private var quoteIDLast4: String {
        String(quote.id.uuidString.prefix(4))
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: quote.clientName,
                subtitle: "報價單 · #\(quoteIDLast4)",
                accent: true,
                onBack: { dismiss() }
            ) {
                StatusBadge(quote.quoteStatus, large: true)
            }

            ScrollView {
                VStack(spacing: Spacing.cardGap) {
                    clientCard
                    factsCard
                    itemsCard
                    totalsCard
                    actionRows
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Cards

    private var clientCard: some View {
        NavigationLink(value: ClientRoute(name: quote.clientName)) {
            AppCard {
                HStack(spacing: 12) {
                    ClientAvatar(name: quote.clientName)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(quote.clientName)
                            .font(AppFont.sans(15, weight: .bold))
                            .foregroundStyle(Color.ink)
                        Text(matchingClient?.phone ?? "尚未加入客戶簿")
                            .font(AppFont.mono(12))
                            .foregroundStyle(Color.inkSoft)
                    }
                    Spacer()
                    HStack(spacing: 2) {
                        Text("查看客戶")
                            .font(AppFont.sans(12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(Color.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var factsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    fact(symbol: "mappin", label: "地點", value: quote.location)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    fact(symbol: "calendar", label: "日期", value: dateString)
                }
                if let folder = quote.folder {
                    fact(symbol: "folder", label: "分類", value: folder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func fact(symbol: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 11))
                Text(label)
            }
            .font(AppFont.sans(11))
            .foregroundStyle(Color.inkSoft)

            Text(value)
                .font(AppFont.sans(14, weight: .medium))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var itemsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("項目明細")
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
                Text("\(formatQty(item.qty)) \(item.unit) × $\(item.price.formatted())")
                    .font(AppFont.mono(12))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer()
            Money(item.subtotal, size: 15, color: .ink)
        }
    }

    private var totalsCard: some View {
        AppCard(accent: true) {
            VStack(spacing: 6) {
                summaryRow("小計", value: subtotal)
                summaryRow("稅金 5%", value: tax)

                Rectangle()
                    .fill(Color.accentSurfaceInk.opacity(0.2))
                    .frame(height: 1)
                    .padding(.vertical, 4)

                HStack {
                    Text("總計")
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
            Text(label)
                .font(AppFont.sans(13))
            Spacer()
            Text("$\(value.formatted())")
                .font(AppFont.mono(13))
        }
        .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
    }

    private var actionRows: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SecondaryButton("傳給客戶", systemImage: "square.and.arrow.up") {
                    // TODO: 觸發 ShareLink / UIActivityViewController
                }
                SecondaryButton("預覽 PDF", systemImage: "doc.text") {
                    // TODO: 顯示 PDFPreviewSheet
                }
            }

            HStack(spacing: 10) {
                SecondaryButton("複製這張", systemImage: "plus") {
                    // TODO: 複製成 draft 跳到 review
                }
                if quote.quoteStatus == .ongoing || quote.quoteStatus == .done {
                    SecondaryButton("轉請款單", systemImage: "dollarsign.circle") {
                        // TODO: 推進 InvoiceScreen
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatQty(_ qty: Double) -> String {
        qty == qty.rounded() ? String(Int(qty)) : "\(qty)"
    }

    private var dateString: String {
        Self.dateFormatter.string(from: quote.date)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview("一般") {
    NavigationStack {
        DetailScreen(quote: PreviewData.makeSampleQuotes()[0])
    }
    .modelContainer(PreviewData.container)
}

#Preview("長地址") {
    let q = PreviewData.makeSampleQuotes()[0]
    q.location = "新北市板橋區文化路二段 150 號 12 樓之 3"
    return NavigationStack {
        DetailScreen(quote: q)
    }
    .modelContainer(PreviewData.container)
}
