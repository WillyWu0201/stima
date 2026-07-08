import SwiftUI

/// 畫面 16 · 訂閱 PRO
/// 從 Settings PRO banner、PDF 模板 PRO badge、4th quote 限制等位置以 fullScreenCover 推進。
///
/// 購買 / 還原透過 `PurchaseManager`（RevenueCat）。沒裝 SDK 時自動 fallback（直接解鎖），
/// 加入套件並填 `TierConfig.revenueCatAPIKey` 後即走真實購買。詳見 PurchaseManager.swift。
struct PaywallScreen: View {
    let onClose: () -> Void
    @Environment(AppSettings.self) private var settings
    @State private var plan: Plan = .yearly

    enum Plan: Hashable { case yearly, monthly }

    private struct Feature {
        let symbol: String
        let title: String
        let sub: String
    }

    private let features: [Feature] = [
        .init(symbol: "doc.text",
              title: "無限張報價單",
              sub: "免費版每月只能 3 張"),
        .init(symbol: "seal",
              title: "自訂 PDF 模板",
              sub: "Logo、抬頭、付款條件、簽名欄、印章"),
        .init(symbol: "sparkles",
              title: "移除浮水印",
              sub: "客戶不會看到「免費版」字樣"),
        .init(symbol: "dollarsign.circle",
              title: "請款單 & 收款追蹤",
              sub: "報價→施工→請款一條龍"),
        .init(symbol: "chart.line.uptrend.xyaxis",
              title: "進階統計與成本記錄",
              sub: "看每案淨利、年度趨勢"),
        .init(symbol: "icloud",
              title: "iCloud 自動備份",
              sub: "換手機也不怕資料不見"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            heroHeader
            ScrollView {
                VStack(spacing: 12) {
                    featureList
                    Spacer(minLength: 8)
                    yearlyCard
                    monthlyCard
                    legalNote
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .safeAreaInset(edge: .bottom) { ctaBar }
    }

    // MARK: - Hero header (accent dark)

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.accentSurfaceInk)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("關閉")

                Spacer()

                Button("還原購買") {
                    restore()
                }
                .font(AppFont.sans(13, weight: .semibold))
                .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
            }

            Text("Stima PRO")
                .font(AppFont.mono(11, weight: .bold))
                .foregroundStyle(Color.accent2)
                .kerning(1.6)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.accent.opacity(0.3), in: Capsule())
                .padding(.top, 14)
                .padding(.bottom, 12)

            Text("報得快、收得回，\n師傅的生意更穩。")
                .font(AppFont.sans(28, weight: .heavy))
                .foregroundStyle(Color.accentSurfaceInk)
                .kerning(-0.6)
                .lineSpacing(2)
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentSurface)
    }

    // MARK: - Feature list

    private var featureList: some View {
        VStack(spacing: 12) {
            ForEach(features.indices, id: \.self) { i in
                featureRow(features[i])
            }
        }
    }

    private func featureRow(_ f: Feature) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accent.opacity(0.12))
                Image(systemName: f.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.accent)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(f.title))
                    .font(AppFont.sans(15, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text(LocalizedStringKey(f.sub))
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Plan picker

    private var yearlyCard: some View {
        planCard(
            plan: .yearly,
            title: "年訂閱",
            sub: "每月只要 $200，年付便宜兩個月",
            price: TierConfig.displayYearlyPrice,
            period: "/ 年",
            badge: TierConfig.displayYearlySaving
        )
    }

    private var monthlyCard: some View {
        planCard(
            plan: .monthly,
            title: "月訂閱",
            sub: "先試一個月看看",
            price: TierConfig.displayMonthlyPrice,
            period: "/ 月",
            badge: nil
        )
    }

    private func planCard(plan target: Plan,
                          title: String,
                          sub: String,
                          price: String,
                          period: String,
                          badge: String?) -> some View {
        let selected = plan == target
        return Button {
            plan = target
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(AppFont.sans(16, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Text(LocalizedStringKey(sub))
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price)
                        .font(AppFont.sans(20, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(Color.ink)
                    Text(LocalizedStringKey(period))
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.inkSoft)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.big, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.big, style: .continuous)
                    .strokeBorder(selected ? Color.accent : Color.borderStrong,
                                  lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if let badge {
                    Text(badge)
                        .font(AppFont.mono(10, weight: .bold))
                        .foregroundStyle(.white)
                        .kerning(0.8)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.accent, in: Capsule())
                        .offset(x: -12, y: -8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Legal note

    private var legalNote: some View {
        Text("7 天免費試用，隨時可取消\n訂閱透過 App Store 收費，可在「設定 → Apple ID」隨時關閉")
            .font(AppFont.sans(11))
            .foregroundStyle(Color.inkSoft)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
    }

    // MARK: - CTA

    private var ctaBar: some View {
        BottomCTA {
            PrimaryButton(ctaLabel, systemImage: "sparkles") {
                subscribe()
            }
        }
    }

    private var ctaLabel: String {
        switch plan {
        case .yearly:  return "訂閱 PRO · 年付 \(TierConfig.displayYearlyPrice)"
        case .monthly: return "訂閱 PRO · 月付 \(TierConfig.displayMonthlyPrice)"
        }
    }

    // MARK: - Purchase actions

    private func subscribe() {
        Task {
            let ok = plan == .yearly
                ? await PurchaseManager.shared.purchaseYearly(into: settings)
                : await PurchaseManager.shared.purchaseMonthly(into: settings)
            if ok { onClose() }
        }
    }

    private func restore() {
        Task {
            if await PurchaseManager.shared.restore(into: settings) { onClose() }
        }
    }
}

#Preview {
    Color.bgPaper
        .ignoresSafeArea()
        .fullScreenCover(isPresented: .constant(true)) {
            PaywallScreen(onClose: {})
                .environment(AppSettings())
        }
}
