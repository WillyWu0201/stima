import SwiftUI

/// 報價單項目列：品名 + 「數量 單位 × 單價」+ 小計。
/// Detail 與確認出單頁共用，避免兩份幾乎相同的 itemRow。
struct QuoteItemRow: View {
    let name: String
    let qty: Double
    let unit: String
    let price: Int
    let subtotal: Int

    @Environment(\.currencySymbol) private var currencySymbol

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(AppFont.sans(14, weight: .semibold))
                    .foregroundStyle(Color.ink)
                Text("\(qtyText) \(unit) × \(currencySymbol)\(price.formatted())")
                    .font(AppFont.mono(12))
                    .foregroundStyle(Color.inkSoft)
            }
            Spacer()
            Money(subtotal, size: 15, color: .ink)
        }
    }

    private var qtyText: String {
        qty == qty.rounded() ? String(Int(qty)) : "\(qty)"
    }
}

/// 深色 hero 卡內的小計列（label 在左、金額在右）。
/// 用於 Detail / 確認出單頁的總計卡。
struct AccentSummaryRow: View {
    let label: LocalizedStringKey
    let value: Int

    @Environment(\.currencySymbol) private var currencySymbol

    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.sans(13))
            Spacer()
            Text("\(currencySymbol)\(value.formatted())")
                .font(AppFont.mono(13))
                .monospacedDigit()
        }
        .foregroundStyle(Color.onAccentMuted)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppCard {
            VStack(spacing: 8) {
                QuoteItemRow(name: "拆除磁磚", qty: 10, unit: "坪", price: 1800, subtotal: 18000)
                AppDivider()
                QuoteItemRow(name: "冷氣排水管", qty: 1, unit: "式", price: 3500, subtotal: 3500)
            }
        }
        AppCard(accent: true) {
            VStack(spacing: 6) {
                AccentSummaryRow(label: "小計", value: 21500)
                AccentSummaryRow(label: "稅金 5%", value: 1075)
            }
        }
    }
    .padding(Spacing.screenH)
    .background(Color.bgPaper)
}
