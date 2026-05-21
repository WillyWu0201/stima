import SwiftUI
import SwiftData

/// 項目詳情頁 — 從 Stats「最常做的項目」推進。
/// 篩出所有 QuoteItem 同名紀錄，顯示累積營收、最近單價、價格趨勢、單價歷史。
struct ItemDetailScreen: View {
    let itemName: String

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    /// 一筆價格紀錄（從 Quote.items 平展抽出）
    private struct Record {
        let date: Date
        let client: String
        let qty: Double
        let unit: String
        let price: Int
        let status: QuoteStatus
    }

    private var records: [Record] {
        var list: [Record] = []
        for q in quotes {
            for it in q.items where it.name == itemName {
                list.append(.init(
                    date:   q.date,
                    client: q.clientName,
                    qty:    it.qty,
                    unit:   it.unit,
                    price:  it.price,
                    status: q.quoteStatus
                ))
            }
        }
        return list.sorted { $0.date > $1.date }
    }

    private var totals: (rev: Int, qty: Double, count: Int, unit: String) {
        var rev = 0, count = 0
        var qty: Double = 0
        var unit = ""
        for r in records {
            rev += Int(r.qty) * r.price
            qty += r.qty
            count += 1
            unit = r.unit
        }
        return (rev, qty, count, unit)
    }

    private var priceStats: (latest: Int, min: Int, max: Int, trendPct: Double) {
        let prices = records.map { $0.price }
        let latest = records.first?.price ?? 0
        let oldest = records.last?.price ?? 0
        let trend: Double = {
            guard oldest > 0, latest != oldest else { return 0 }
            return Double(latest - oldest) / Double(oldest) * 100
        }()
        return (latest, prices.min() ?? 0, prices.max() ?? 0, trend)
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: itemName,
                      subtitle: "項目分析",
                      onBack: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    heroCard
                    miniRow
                    SectionTitle("單價歷史")
                    historyList
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Hero

    private var heroCard: some View {
        let t = totals
        return AppCard(accent: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("累積營收（\(t.count) 次）")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
                    .kerning(1.2)
                    .textCase(.uppercase)

                Money(t.rev, size: 30, color: .accent2)

                Text("共做了 \(formatQty(t.qty)) \(t.unit)")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.accentSurfaceInk.opacity(0.6))
            }
        }
    }

    // MARK: - Mini stats（最近單價 / 價格趨勢）

    private var miniRow: some View {
        let p = priceStats
        let unit = totals.unit
        return HStack(spacing: 10) {
            miniLatestPrice(latest: p.latest, unit: unit)
            miniTrend(pct: p.trendPct, min: p.min, max: p.max)
        }
    }

    private func miniLatestPrice(latest: Int, unit: String) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("最近單價")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .kerning(1.2)
                    .textCase(.uppercase)
                Money(latest, size: 18, color: .ink)
                Text("/ \(unit)")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func miniTrend(pct: Double, min: Int, max: Int) -> some View {
        let color: Color = pct > 0 ? .accent : (pct < 0 ? .positive : .inkSoft)
        let symbol = pct > 0 ? "▲" : (pct < 0 ? "▼" : "—")
        return AppCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("價格趨勢")
                    .font(AppFont.mono(11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .kerning(1.2)
                    .textCase(.uppercase)
                Text("\(symbol) \(String(format: "%.1f%%", abs(pct)))")
                    .font(AppFont.sans(18, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text("範圍 $\(min.formatted())–$\(max.formatted())")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - History list

    private var historyList: some View {
        let p = priceStats
        return AppCard(padded: false) {
            VStack(spacing: 0) {
                ForEach(Array(records.enumerated()), id: \.offset) { index, r in
                    historyRow(r, isMax: r.price == p.max && p.min != p.max,
                               isMin: r.price == p.min && p.min != p.max)
                    if index < records.count - 1 {
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    private func historyRow(_ r: Record, isMax: Bool, isMin: Bool) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(r.client)
                    .font(AppFont.sans(14, weight: .semibold))
                    .foregroundStyle(Color.ink)
                Text("\(Self.dateFormatter.string(from: r.date)) · \(formatQty(r.qty)) \(r.unit)")
                    .font(AppFont.mono(11))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer()
            Money(r.price, size: 14, color: .ink)
            if isMax {
                tag("最高", color: .accent)
            } else if isMin {
                tag("最低", color: .positive)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func tag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppFont.mono(10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15), in: Capsule())
    }

    // MARK: - Helpers

    private func formatQty(_ qty: Double) -> String {
        qty == qty.rounded() ? "\(Int(qty))" : "\(qty)"
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview {
    NavigationStack {
        ItemDetailScreen(itemName: "木作天花板")
    }
    .modelContainer(PreviewData.container)
}
