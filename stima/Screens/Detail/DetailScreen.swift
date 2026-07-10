import SwiftUI
import SwiftData

/// 畫面 09 · 報價單詳情
/// 從 Home 推進，顯示完整內容並提供主要操作（傳給客戶 / 預覽 PDF / 複製 / 轉請款單）。
struct DetailScreen: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Query private var allClients: [Client]
    @Query private var allQuotes: [Quote]
    @State private var pdfPreviewOpen = false
    @State private var goingToInvoice = false
    @State private var showingCopyFlow = false
    @State private var showingEditFlow = false
    @State private var showingLimitAlert = false
    @State private var showingPaywall = false

    private var matchingClient: Client? {
        allClients.first { $0.name == quote.clientName }
    }

    private var subtotal: Int {
        quote.items.reduce(0) { $0 + $1.subtotal }
    }

    /// 從已存的 total 反推稅金，確保明細加總永遠等於出單當下的金額（即使之後改了稅率設定）。
    private var tax: Int { max(0, quote.total - subtotal) }

    private var taxPercent: Int {
        subtotal > 0 ? Int((Double(tax) / Double(subtotal) * 100).rounded()) : 0
    }

    private var quoteIDLast4: String {
        String(quote.id.uuidString.prefix(4))
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "\(quote.clientName)",
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
        .sheet(isPresented: $pdfPreviewOpen) {
            PDFPreviewSheet(quote: quote)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $goingToInvoice) {
            InvoiceScreen(quote: quote)
        }
        .fullScreenCover(isPresented: $showingCopyFlow) {
            NewQuoteFlow(
                initialDraft: makeCopyDraft(),
                startAt:      .review,
                onClose:      { showingCopyFlow = false },
                onFinished:   { showingCopyFlow = false }
            )
        }
        .fullScreenCover(isPresented: $showingEditFlow) {
            NewQuoteFlow(
                initialDraft: .from(quote),
                editingQuote: quote,
                onClose:      { showingEditFlow = false },
                onFinished:   { showingEditFlow = false }
            )
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallScreen { showingPaywall = false }
                .environment(settings)
        }
        .alert("本月免費額度已用完", isPresented: $showingLimitAlert) {
            Button("升級 PRO") { showingPaywall = true }
            Button("再看看", role: .cancel) {}
        } message: {
            Text("免費版每月最多 \(TierConfig.freeMonthlyQuoteLimit) 張報價單，下個月會自動重置。升級 PRO 解鎖無限張。")
        }
    }

    /// 從現有 quote 內容 clone 出一張 draft（新日期），用在「複製這張」流程。
    private func makeCopyDraft() -> NewQuoteDraft {
        let d = NewQuoteDraft()
        d.clientName = quote.clientName
        d.location   = quote.location
        d.date       = .now
        d.folder     = quote.folder
        d.items      = quote.items.map {
            .init(name: $0.name, unit: $0.unit, qty: $0.qty, price: $0.price, cost: $0.cost)
        }
        return d
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
                Text(LocalizedStringKey(label))
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
                    let item = quote.items[i]
                    QuoteItemRow(name: item.name, qty: item.qty, unit: item.unit,
                                 price: item.price, subtotal: item.subtotal)
                        .padding(.vertical, 8)
                    if i < quote.items.count - 1 {
                        AppDivider()
                    }
                }
            }
        }
    }

    private var totalsCard: some View {
        AppCard(accent: true) {
            VStack(spacing: 6) {
                AccentSummaryRow(label: "小計", value: subtotal)
                AccentSummaryRow(label: "稅金 \(taxPercent)%", value: tax)

                Rectangle()
                    .fill(Color.onAccentLine)
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

    private var actionRows: some View {
        GlassGroup(spacing: 10) {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ShareSecondaryButton(
                        title: "傳給客戶",
                        message: ShareMessage.forQuote(quote, masterName: settings.masterName, currencySymbol: settings.currencySymbol)
                    )
                    SecondaryButton("預覽 PDF", systemImage: "doc.text") {
                        pdfPreviewOpen = true
                    }
                }

                HStack(spacing: 10) {
                    SecondaryButton("編輯", systemImage: "pencil") {
                        showingEditFlow = true
                    }
                    SecondaryButton("複製這張", systemImage: "plus") {
                        if TierGate.canCreateQuote(isPro: settings.isPro, quotes: allQuotes) {
                            showingCopyFlow = true
                        } else {
                            showingLimitAlert = true
                        }
                    }
                }
                if quote.quoteStatus == .ongoing {
                    HStack(spacing: 10) {
                        SecondaryButton("標記完工", systemImage: "checkmark.circle") {
                            markAsDone()
                        }
                        SecondaryButton("轉請款單", systemImage: "dollarsign.circle") {
                            goingToInvoice = true
                        }
                    }
                } else if quote.quoteStatus == .done {
                    SecondaryButton("轉請款單", systemImage: "dollarsign.circle") {
                        goingToInvoice = true
                    }
                }
            }
        }
    }

    /// 進行中 → 已完工（工程做完、待收款）。狀態徽章會即時更新。
    private func markAsDone() {
        quote.status = QuoteStatus.done.rawValue
    }

    // MARK: - Helpers

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
