import SwiftUI
import SwiftData

/// 畫面 10 · 營運統計
/// year switcher → hero (paid total + YoY) → mini stats → monthly bar chart
/// → top client → top items（最常做）
struct StatsScreen: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.currencySymbol) private var currencySymbol
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    @State private var year: Int = Calendar.current.component(.year, from: .now)
    @State private var paywallOpen = false

    private var availableYears: [Int] {
        let years = YearStatsCalculator.availableYears(quotes: quotes)
        // 沒資料時至少顯示今年
        return years.isEmpty ? [year] : years
    }

    private var stats: YearStats {
        YearStatsCalculator.compute(quotes: quotes, year: year)
    }

    private var displayName: String {
        let n = settings.masterName.trimmingCharacters(in: .whitespaces)
        return n.isEmpty ? "陳師傅" : n
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "營運統計", subtitle: "\(displayName)", accent: true)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    yearSwitcher
                    heroCard
                    miniStats

                    SectionTitle("淨利（進階）")
                    if settings.isPro {
                        netProfitCard
                    } else {
                        netProfitLockedCard
                    }

                    SectionTitle("每月已收款")
                    monthlyChart

                    if let top = stats.topClient {
                        SectionTitle("最大客戶")
                        topClientCard(top)
                    }

                    if !stats.topItems.isEmpty {
                        SectionTitle("最常做的項目")
                        topItemsList
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 14)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 若預設年份在資料中不存在，切到最近一年
            if !availableYears.contains(year), let first = availableYears.first {
                year = first
            }
        }
        .fullScreenCover(isPresented: $paywallOpen) {
            PaywallScreen { paywallOpen = false }
                .environment(settings)
        }
    }

    // MARK: - Year switcher

    private var yearSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableYears, id: \.self) { y in
                    Button {
                        year = y
                    } label: {
                        Text("\(String(y)) 年")
                            .font(AppFont.sans(13, weight: .semibold))
                            .foregroundStyle(year == y ? .white : Color.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(year == y ? Color.accent : Color.clear,
                                        in: Capsule())
                            .overlay(
                                Capsule().strokeBorder(
                                    year == y ? Color.accent : Color.appBorder,
                                    lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .fixedSize()
                }
            }
        }
    }

    // MARK: - Hero card

    private var heroCard: some View {
        AppCard(accent: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(String(year)) 年已收款 · \(stats.paidCount) 張")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.onAccentMuted)
                    .kerning(1.4)
                    .textCase(.uppercase)

                Money(stats.paidTotal, size: 36, color: .accent2)

                if let pct = stats.yoyPercent, let prev = stats.prevYearPaid {
                    HStack(spacing: 4) {
                        Image(systemName: pct >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("比去年同期 \(pct >= 0 ? "▲" : "▼") \(String(format: "%.1f%%", abs(pct)))（去年 \(currencySymbol)\(prev.formatted())）")
                    }
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.onAccentFaint)
                }
            }
        }
    }

    // MARK: - Mini stats（待收款 + 進行中）

    private var miniStats: some View {
        HStack(spacing: 10) {
            miniStat(label: "待收款", value: stats.doneTotal,
                     sub: "\(stats.doneCount) 張待收款", color: .positive)
            miniStat(label: "進行中", value: stats.ongoingTotal,
                     sub: "\(stats.ongoingCount) 張施工", color: .accent)
        }
    }

    private func miniStat(label: String, value: Int, sub: String, color: Color) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(label))
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .kerning(1.2)
                    .textCase(.uppercase)

                Money(value, size: 17, color: color)

                Text(sub)
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 淨利卡（PRO · 用各項目成本算）

    private var netProfitCard: some View {
        AppCard {
            HStack(alignment: .top, spacing: 12) {
                netProfitCell(label: "成本", value: stats.costTotal, color: .inkMid)
                netProfitCell(label: "淨利", value: stats.netProfit, color: .positive)
                VStack(alignment: .leading, spacing: 6) {
                    Text("淨利率")
                        .font(AppFont.mono(11, weight: .semibold))
                        .foregroundStyle(Color.inkSoft)
                        .kerning(1.2)
                        .textCase(.uppercase)
                    Text(stats.marginPercent.map { String(format: "%.0f%%", $0) } ?? "—")
                        .font(AppFont.sans(17, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(stats.marginPercent == nil ? Color.inkFaint : Color.positive)
                    Text("已收款扣成本")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// 免費用戶：不隱藏功能，改顯示鎖定 teaser → 點擊導向 Paywall（符合「不可靜默略過，要 upsell」）。
    private var netProfitLockedCard: some View {
        Button {
            paywallOpen = true
        } label: {
            AppCard {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.inkFaint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("看每張單的成本與淨利")
                            .font(AppFont.sans(15, weight: .semibold))
                            .foregroundStyle(Color.ink)
                        Text("PRO 專屬 · 升級解鎖淨利與淨利率統計")
                            .font(AppFont.sans(12))
                            .foregroundStyle(Color.inkSoft)
                    }
                    Spacer()
                    Text("升級")
                        .font(AppFont.sans(13, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accent, in: Capsule())
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func netProfitCell(label: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedStringKey(label))
                .font(AppFont.mono(11, weight: .semibold))
                .foregroundStyle(Color.inkSoft)
                .kerning(1.2)
                .textCase(.uppercase)
            Money(value, size: 17, color: color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Monthly chart

    private var monthlyChart: some View {
        AppCard {
            VStack(spacing: 5) {
                ForEach(0..<12, id: \.self) { i in
                    monthRow(monthIndex: i)
                }
            }
        }
    }

    private func monthRow(monthIndex i: Int) -> some View {
        let amt = stats.monthly[i]
        let pct = stats.maxMonthly > 0 ? Double(amt) / Double(stats.maxMonthly) : 0
        let isMax = amt == stats.maxMonthly && amt > 0
        return HStack(spacing: 8) {
            Text(MonthLabel.zhHant[i])
                .font(AppFont.mono(11))
                .foregroundStyle(Color.inkSoft)
                .frame(width: 28, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.bgSoft)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(isMax ? Color.accent : Color.accent2)
                        .frame(width: geo.size.width * pct)
                }
            }
            .frame(height: 16)

            Text(amt > 0 ? "$\(Int(round(Double(amt) / 1000)))k" : "—")
                .font(AppFont.mono(11))
                .foregroundStyle(amt > 0 ? Color.ink : Color.inkFaint)
                .frame(width: 60, alignment: .trailing)
        }
    }

    // MARK: - Top client card

    private func topClientCard(_ top: YearStats.TopClient) -> some View {
        NavigationLink(value: ClientRoute(name: top.name)) {
            AppCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("🏆 \(top.name)")
                                .font(AppFont.sans(16, weight: .bold))
                                .foregroundStyle(Color.ink)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.inkFaint)
                        }
                        Text("\(top.count) 次合作")
                            .font(AppFont.sans(12))
                            .foregroundStyle(Color.inkSoft)
                    }
                    Spacer()
                    Money(top.total, size: 18)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Top items list

    private var topItemsList: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                ForEach(Array(stats.topItems.enumerated()), id: \.element.id) { index, item in
                    topItemRow(rank: index + 1, item: item)
                    if index < stats.topItems.count - 1 {
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    private func topItemRow(rank: Int, item: YearStats.TopItem) -> some View {
        NavigationLink(value: ItemRoute(name: item.name)) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(rank == 1 ? Color.accent : Color.bgSoft)
                    Text("\(rank)")
                        .font(AppFont.mono(12, weight: .bold))
                        .foregroundStyle(rank == 1 ? .white : Color.inkSoft)
                }
                .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(AppFont.sans(14, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    Text("\(item.count) 次 · 共 \(Int(item.totalQty)) \(item.unit)")
                        .font(AppFont.mono(11))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer()
                Money(item.totalRev, size: 13, color: .inkMid)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.inkFaint)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        StatsScreen()
    }
    .environment(PreviewData.settings)
    .modelContainer(PreviewData.container)
}
