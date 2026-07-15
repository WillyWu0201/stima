import SwiftUI

/// 畫面 06 · 確認出單
/// 第一次出單時詢問「報價單抬頭」（會存到 AppSettings.masterName）。
/// 客戶卡 / 項目卡 / 總計卡。出單按下後由 NewQuoteFlow 寫入 SwiftData。
struct NewQuoteReviewScreen: View {
    @Bindable var draft: NewQuoteDraft
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Environment(TutorialState.self) private var tutorial
    @State private var coachDone = false

    private var askName: Bool {
        settings.masterName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var canFinish: Bool {
        !askName && !draft.items.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "確認出單",
                subtitle: "新增報價單 · 3 / 3",
                onBack: { dismiss() }
            )

            ScrollView {
                VStack(spacing: Spacing.cardGap) {
                    if askName {
                        nameCard
                    }
                    customerCard
                    itemsCard
                    totalsCard
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            BottomCTA {
                PrimaryButton("出單，搞定!", systemImage: "checkmark") {
                    onFinish()
                }
                .disabled(!canFinish)
                .coachAnchor("review")
            }
        }
        .coachMark(active: tutorial.coachingActive && !coachDone,
                   target: "review",
                   text: "填一下抬頭（你的店名或稱呼），金額沒問題就按「出單」，完成第一張！") {
            coachDone = true
        }
    }

    // MARK: - Cards

    private var nameCard: some View {
        @Bindable var settings = settings
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .font(.system(size: 12))
                Text("報價單抬頭 · 第一次問，之後記著")
                    .font(AppFont.sans(11, weight: .semibold))
                    .kerning(0.5)
            }
            .foregroundStyle(Color.inkSoft)

            AppTextField(text: $settings.masterName,
                         placeholder: "例：Stima")
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceAlt,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.appBorder, lineWidth: 1)
        )
    }

    private var customerCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("客戶")
                            .font(AppFont.mono(11, weight: .semibold))
                            .foregroundStyle(Color.inkSoft)
                            .kerning(1.2)
                            .textCase(.uppercase)
                        Text(draft.clientName.isEmpty ? "未命名客戶" : draft.clientName)
                            .font(AppFont.sans(18, weight: .bold))
                            .foregroundStyle(Color.ink)
                    }
                    Spacer()
                    Text(Self.dateFormatter.string(from: draft.date))
                        .font(AppFont.mono(12))
                        .foregroundStyle(Color.inkSoft)
                }

                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 11, weight: .semibold))
                    Text(draft.location.isEmpty ? "— 未填地點 —" : draft.location)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkSoft)
            }
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

                if draft.items.isEmpty {
                    Text("還沒有項目")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkFaint)
                        .padding(.vertical, 12)
                } else {
                    ForEach(draft.items.indices, id: \.self) { i in
                        let item = draft.items[i]
                        QuoteItemRow(name: item.name, qty: item.qty, unit: item.unit,
                                     price: item.price, subtotal: item.subtotal)
                            .padding(.vertical, 8)
                        if i < draft.items.count - 1 {
                            AppDivider()
                        }
                    }
                }
            }
        }
    }

    private var totalsCard: some View {
        AppCard(accent: true) {
            VStack(spacing: 6) {
                AccentSummaryRow(label: "小計", value: draft.subtotal)
                AccentSummaryRow(label: "稅金 \(Int(settings.taxRate))%",
                                 value: draft.tax(ratePercent: settings.taxRate))

                Rectangle()
                    .fill(Color.onAccentLine)
                    .frame(height: 1)
                    .padding(.vertical, 4)

                HStack {
                    Text("總計")
                        .font(AppFont.sans(14, weight: .bold))
                        .foregroundStyle(Color.accentSurfaceInk)
                    Spacer()
                    Money(draft.total(ratePercent: settings.taxRate), size: 26, color: .accent2)
                }
            }
        }
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview("第一次出單") {
    let draft = NewQuoteDraft()
    draft.clientName = "王先生"
    draft.location = "台北市信義區"
    draft.items = [
        .init(name: "拆除磁磚", unit: "坪", qty: 10, price: 1800),
        .init(name: "冷氣排水管", unit: "式", qty: 1, price: 3500),
        .init(name: "油漆批土", unit: "坪", qty: 25, price: 850),
    ]
    return NavigationStack {
        NewQuoteReviewScreen(draft: draft, onFinish: {})
    }
    .environment(AppSettings())     // 空抬頭
    .environment(TutorialState())
}

#Preview("已有抬頭") {
    let draft = NewQuoteDraft()
    draft.clientName = "王先生"
    draft.location = "台北市信義區"
    draft.items = [
        .init(name: "拆除磁磚", unit: "坪", qty: 10, price: 1800),
    ]
    let settings = AppSettings()
    settings.masterName = "陳師傅"
    return NavigationStack {
        NewQuoteReviewScreen(draft: draft, onFinish: {})
    }
    .environment(settings)
    .environment(TutorialState())
}
