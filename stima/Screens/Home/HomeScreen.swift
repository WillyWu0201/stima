import SwiftUI
import SwiftData

/// 畫面 08 · 報價單列表（Home）
/// 主要 landing 畫面：accent header + search + filter tabs + quote cards。
struct HomeScreen: View {
    @Environment(AppSettings.self) private var settings
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    @State private var search: String = ""
    @State private var selectedTab: FilterTab = .all
    @State private var showingNewQuote = false

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
    }

    // MARK: - Sections

    private var header: some View {
        AppHeader(
            title: "我的報價單",
            subtitle: "歡迎，\(displayName)",
            accent: true
        ) {
            Button {
                showingNewQuote = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.accent2)
            }
            .accessibilityLabel("新增報價單")
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

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("🔍")
                .font(.system(size: 36))
            Text("這個分頁還是空的")
                .font(AppFont.sans(14))
                .foregroundStyle(Color.inkSoft)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
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
    .modelContainer(PreviewData.container)
}
