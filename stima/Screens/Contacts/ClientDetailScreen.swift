import SwiftUI
import SwiftData

/// 客戶詳情頁 — 從 Contacts / Stats / DetailScreen 的「查看客戶 →」推進。
/// 用 clientName 在所有 quotes 內篩出該客戶的歷史紀錄，並從 Client 表撈完整聯絡資訊。
struct ClientDetailScreen: View {
    let clientName: String

    @Environment(\.dismiss) private var dismiss
    @Query private var allQuotes: [Quote]
    @Query private var allClients: [Client]
    @State private var editOpen = false

    private var client: Client? {
        allClients.first { $0.name == clientName }
    }

    private var history: [Quote] {
        allQuotes
            .filter { $0.clientName == clientName }
            .sorted { $0.date > $1.date }
    }

    private var totalPaid: Int {
        var sum = 0
        for q in history where q.quoteStatus == .paid { sum += q.total }
        return sum
    }

    private var totalDone: Int {
        var sum = 0
        for q in history where q.quoteStatus == .done { sum += q.total }
        return sum
    }

    private var doneCount: Int {
        history.filter { $0.quoteStatus == .done }.count
    }

    private var favItems: [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for q in history {
            for it in q.items {
                counts[it.name, default: 0] += 1
            }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(4)
            .map { (name: $0.key, count: $0.value) }
    }

    private var firstYearMonth: String? {
        guard let first = history.last else { return nil }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: first.date)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: clientName,
                subtitle: "客戶詳情",
                onBack: { dismiss() }
            ) {
                if client != nil {
                    Button("編輯") { editOpen = true }
                        .font(AppFont.sans(15, weight: .semibold))
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    heroCard
                    if let c = client {
                        contactCard(c)
                    }
                    if totalDone > 0 {
                        pendingCard
                    }
                    if !favItems.isEmpty {
                        SectionTitle("常為他做")
                        favItemTags
                    }
                    SectionTitle("歷史報價單（\(history.count) 張）")
                    historyList
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $editOpen) {
            if let c = client {
                NewClientSheet(
                    existingNames: Set(allClients.map(\.name)).subtracting([c.name]),
                    editingClient: c
                ) { _ in }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Cards

    private var heroCard: some View {
        AppCard(accent: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("累計營收")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
                    .kerning(1.2)
                    .textCase(.uppercase)

                Money(totalPaid, size: 32, color: .accent2)

                HStack(spacing: 0) {
                    Text("合作 \(history.count) 次")
                    if let ym = firstYearMonth {
                        Text("  ·  自 \(ym) 起")
                    }
                }
                .font(AppFont.sans(13))
                .foregroundStyle(Color.accentSurfaceInk.opacity(0.6))
            }
        }
    }

    private func contactCard(_ c: Client) -> some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                if !c.phone.isEmpty {
                    contactRow(systemImage: "phone", color: .cool, value: c.phone,
                               chipLabel: "撥打", chipColor: .cool) {
                        callPhone(c.phone)
                    }
                }
                if !c.email.isEmpty {
                    if !c.phone.isEmpty { divider }
                    contactRow(systemImage: "envelope", color: .inkSoft, value: c.email)
                }
                if !c.address.isEmpty {
                    if !c.phone.isEmpty || !c.email.isEmpty { divider }
                    contactRow(systemImage: "mappin", color: .accent, value: c.address,
                               chipLabel: "導航", chipColor: .accent, wrap: true) {
                        openMaps(c.address)
                    }
                }
                if !c.notes.isEmpty {
                    divider
                    HStack(alignment: .top, spacing: 6) {
                        Text("📝")
                        Text(c.notes)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSoft)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.surfaceAlt)
                }
            }
        }
    }

    private func contactRow(systemImage: String, color: Color, value: String,
                            chipLabel: String? = nil,
                            chipColor: Color = .accent,
                            wrap: Bool = false,
                            action: (() -> Void)? = nil) -> some View {
        HStack(alignment: wrap ? .top : .center, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 16, alignment: .center)
                .padding(.top, wrap ? 2 : 0)

            Text(value)
                .font(systemImage == "phone" ? AppFont.mono(13) : AppFont.sans(13))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: wrap)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let chipLabel, let action {
                Button(action: action) {
                    Text(chipLabel)
                        .font(AppFont.sans(12, weight: .bold))
                        .foregroundStyle(chipColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(chipColor.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appBorder)
            .frame(height: 1)
            .padding(.leading, 40)
    }

    private var pendingCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("待收款")
                .font(AppFont.mono(11, weight: .semibold))
                .foregroundStyle(Color.inkSoft)
                .kerning(1.2)
                .textCase(.uppercase)
            Money(totalDone, size: 20, color: .positive)
            Text("\(doneCount) 張已完工待收")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.inkSoft)
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSurface,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.positive)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.appBorder, lineWidth: 1)
        )
    }

    private var favItemTags: some View {
        FlowRow(spacing: 6) {
            ForEach(favItems, id: \.name) { item in
                HStack(spacing: 4) {
                    Text(item.name)
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.ink)
                    Text("×\(item.count)")
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.inkFaint)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.appSurface, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.appBorder, lineWidth: 1))
            }
        }
    }

    private var historyList: some View {
        VStack(spacing: 10) {
            ForEach(history) { quote in
                NavigationLink(value: quote) {
                    historyCard(quote)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func historyCard(_ q: Quote) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(Self.dateFormatter.string(from: q.date))
                        .font(AppFont.mono(13))
                        .foregroundStyle(Color.inkSoft)
                    Spacer()
                    StatusBadge(q.quoteStatus)
                }
                .padding(.bottom, 6)

                Text(q.location)
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSoft)
                    .padding(.bottom, 8)

                AppDivider()
                    .padding(.bottom, 8)

                HStack {
                    Text("\(q.items.count) 個項目")
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.inkSoft)
                    Spacer()
                    Money(q.total, size: 16)
                }
            }
        }
    }

    // MARK: - Actions

    private func callPhone(_ phone: String) {
        let digits = phone.filter { $0.isNumber }
        guard !digits.isEmpty, let url = URL(string: "tel:\(digits)") else { return }
        UIApplication.shared.open(url)
    }

    private func openMaps(_ address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "http://maps.apple.com/?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: -

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview {
    NavigationStack {
        ClientDetailScreen(clientName: "陳老闆")
            .navigationDestination(for: Quote.self) { _ in
                Text("Detail")
            }
    }
    .modelContainer(PreviewData.container)
}
