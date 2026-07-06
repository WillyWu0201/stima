import SwiftUI
import SwiftData

/// 畫面 08 · 報價單列表（Home）
/// 主要 landing 畫面：accent header + search + filter tabs + quote cards。
struct HomeScreen: View {
    @Environment(AppSettings.self) private var settings
    @Environment(TutorialState.self) private var tutorial
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    @State private var search: String = ""
    @State private var selectedTab: FilterTab = .all
    @State private var showingNewQuote = false
    @State private var showingLimitAlert = false
    @State private var showingPaywall = false

    enum FilterTab: Hashable {
        case all
        case status(QuoteStatus)
        case folder(String)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchAndTabs
            quoteList
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showingNewQuote) {
            NewQuoteFlow(
                onClose:    { showingNewQuote = false },
                onFinished: { showingNewQuote = false }
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
        .onAppear {
            // 從 onboarding「來試一張看看」進來：自動開新報價並帶 coach mark。
            if tutorial.requestQuoteTutorial {
                tutorial.requestQuoteTutorial = false
                tutorial.coachingActive = true
                showingNewQuote = true
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        AppHeader(
            title: "我的報價單",
            subtitle: "歡迎，\(displayName)",
            accent: true
        ) {
            Button(action: startNewQuote) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.accent2)
            }
            .accessibilityLabel("新增報價單")
        }
    }

    /// 進新增報價單流程；超過免費額度則導向升級提示。
    /// Header 的「+」與空狀態的 CTA 共用。
    private func startNewQuote() {
        if TierGate.canCreateQuote(isPro: settings.isPro, quotes: quotes) {
            showingNewQuote = true
        } else {
            showingLimitAlert = true
        }
    }

    private var searchAndTabs: some View {
        VStack(spacing: 14) {
            SearchField(text: $search, placeholder: "搜尋客戶、地點、項目（例：冷氣）")
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    TabChip(
                        label: "全部",
                        count: quotes.count,
                        isActive: selectedTab == .all
                    ) { selectedTab = .all }

                    ForEach([QuoteStatus.ongoing, .done, .paid], id: \.self) { status in
                        TabChip(
                            label: status.label,
                            count: countByStatus(status),
                            isActive: selectedTab == .status(status)
                        ) { selectedTab = .status(status) }
                    }

                    ForEach(availableFolders, id: \.self) { folder in
                        TabChip(
                            label: folder,
                            count: countByFolder(folder),
                            isActive: selectedTab == .folder(folder),
                            isFolder: true
                        ) { selectedTab = .folder(folder) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var quoteList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                if filteredQuotes.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredQuotes) { quote in
                        NavigationLink(value: quote) {
                            QuoteCard(quote: quote)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if quotes.isEmpty {
            // 全新使用者：給明確的第一步，不要只丟一個空畫面。
            EmptyStateView(
                systemImage: "doc.text.magnifyingglass",
                title: "還沒有報價單",
                message: "建好第一張，客戶、項目、收款都從這裡開始。"
            ) {
                PrimaryButton("建立第一張報價單", systemImage: "plus", action: startNewQuote)
            }
        } else {
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: search.isEmpty ? "這個分頁還是空的" : "找不到符合的報價單"
            )
        }
    }

    // MARK: - Derived data

    private var displayName: String {
        let name = settings.masterName.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "陳師傅" : name
    }

    /// 出現過的 folder，保持依時間排序的原始順序。
    private var availableFolders: [String] {
        var seen = Set<String>()
        return quotes.compactMap { q -> String? in
            guard let f = q.folder, !seen.contains(f) else { return nil }
            seen.insert(f)
            return f
        }
    }

    private var filteredQuotes: [Quote] {
        let byTab: [Quote] = {
            switch selectedTab {
            case .all:               return quotes
            case .status(let s):     return quotes.filter { $0.quoteStatus == s }
            case .folder(let f):     return quotes.filter { $0.folder == f }
            }
        }()
        guard !search.isEmpty else { return byTab }
        return byTab.filter {
            $0.clientName.localizedStandardContains(search)
            || $0.location.localizedStandardContains(search)
            || $0.items.contains { $0.name.localizedStandardContains(search) }
        }
    }

    private func countByStatus(_ s: QuoteStatus) -> Int {
        quotes.filter { $0.quoteStatus == s }.count
    }

    private func countByFolder(_ f: String) -> Int {
        quotes.filter { $0.folder == f }.count
    }
}

#Preview {
    NavigationStack {
        HomeScreen()
            .navigationDestination(for: Quote.self) { quote in
                DetailScreen(quote: quote)
            }
    }
    .environment(PreviewData.settings)
    .environment(TutorialState())
    .modelContainer(PreviewData.container)
}
