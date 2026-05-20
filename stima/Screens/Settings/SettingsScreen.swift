import SwiftUI
import SwiftData

/// 畫面 11 · 設定
/// Top-level tab，把 AppSettings 大多數欄位接到 UI。
/// 項目分類管理 / 自訂項目管理留在下個 commit。
struct SettingsScreen: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        VStack(spacing: 0) {
            AppHeader(title: "設定", subtitle: "師傅號 · v2.0", accent: true)

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    proBanner

                    SectionTitle("同步與備份")
                    iCloudCard

                    SectionTitle("個人")
                    masterNameCard(settings: $settings.masterName)

                    SectionTitle("商務")
                    businessCard

                    SectionTitle("項目分類")
                    Text("分類管理 — TODO")     // 下個 commit
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.appSurface,
                                    in: RoundedRectangle(cornerRadius: Radius.card,
                                                         style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.card,
                                             style: .continuous)
                                .strokeBorder(Color.appBorder, lineWidth: 1)
                        )

                    SectionTitle("我的自訂項目")
                    Text("自訂項目 — TODO")     // 下個 commit
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color.appSurface,
                                    in: RoundedRectangle(cornerRadius: Radius.card,
                                                         style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.card,
                                             style: .continuous)
                                .strokeBorder(Color.appBorder, lineWidth: 1)
                        )

                    SectionTitle("國際化")
                    internationalCard

                    SectionTitle("其他")
                    miscCard

                    buildStamp
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - PRO banner

    @ViewBuilder
    private var proBanner: some View {
        if settings.isPro {
            // 已訂閱：positive 左邊框
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.positive)
                VStack(alignment: .leading, spacing: 2) {
                    Text("師傅號 PRO · 已訂閱")
                        .font(AppFont.sans(15, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Text("下次扣款 2027-05-20 · 年費 $2,400")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer()
            }
            .padding(Spacing.card)
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
        } else {
            // 未訂閱：accent dark 升級卡
            Button {
                // TODO: 推進 PaywallScreen
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.accent2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("升級到師傅號 PRO")
                            .font(AppFont.sans(15, weight: .bold))
                            .foregroundStyle(Color.accent2)
                        Text("無限報價單 · 自訂模板 · 移除浮水印 · iCloud 備份")
                            .font(AppFont.sans(11))
                            .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.accentSurfaceInk)
                }
                .padding(Spacing.card)
                .background(Color.accentSurface,
                            in: RoundedRectangle(cornerRadius: Radius.card,
                                                 style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - iCloud sync

    private var iCloudCard: some View {
        AppCard {
            HStack(spacing: 10) {
                Circle()
                    .fill(settings.isPro ? Color.positive : Color.inkFaint)
                    .frame(width: 8, height: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text("iCloud 自動備份")
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    Text(settings.isPro
                         ? "已啟用 · 最後同步 12 秒前"
                         : "需要 PRO · 換手機資料自動還原")
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.inkSoft)
                }
                Spacer()
                Toggle("", isOn: .constant(settings.isPro))
                    .labelsHidden()
                    .tint(Color.accent)
                    .disabled(true)     // 切換 by Paywall 流程，這個只是顯示
            }
        }
    }

    // MARK: - 抬頭

    private func masterNameCard(settings nameBinding: Binding<String>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("報價單抬頭")
                    .font(AppFont.sans(12, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)

                AppTextField(text: nameBinding,
                             placeholder: "例：陳師傅 / 大發工程行")

                Text("出現在每張報價單的左上方")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkFaint)
            }
        }
    }

    // MARK: - 商務（入口）

    private var businessCard: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                SettingsRow(
                    systemImage: "person",
                    iconColor: .accent,
                    label: "客戶簿",
                    hint: "所有客戶與聯絡資料"
                ) {
                    // TODO: 推進 ContactsScreen
                }
                rowDivider
                SettingsRow(
                    systemImage: "doc.text",
                    iconColor: .accent,
                    label: "報價單模板（PDF）",
                    hint: "Logo、抬頭、付款條件、印章",
                    proLabel: !settings.isPro
                ) {
                    // TODO: 推進 PDFTemplateScreen
                }
            }
        }
    }

    // MARK: - 國際化

    private var internationalCard: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                SettingsRow(
                    systemImage: "dollarsign.circle",
                    iconColor: .cool,
                    label: "貨幣",
                    rightValue: Self.currencyLabel(settings.currency)
                ) { /* TODO: 切換 */ }
                rowDivider
                SettingsRow(
                    systemImage: "globe",
                    iconColor: .cool,
                    label: "語言",
                    rightValue: Self.languageLabel(settings.language)
                ) { /* TODO: 切換 */ }
                rowDivider
                SettingsRow(
                    systemImage: "percent",
                    iconColor: .cool,
                    label: "稅制",
                    rightValue: "\(Int(settings.taxRate))% · \(Self.taxRegion(settings.currency))"
                ) { /* TODO: 切換 */ }
            }
        }
    }

    // MARK: - 其他

    private var miscCard: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                SettingsRow(
                    systemImage: "square.and.arrow.up",
                    iconColor: .inkSoft,
                    label: "匯出全部資料",
                    hint: "備份成 Excel / CSV"
                ) { /* TODO */ }
                rowDivider
                SettingsRow(
                    systemImage: "gearshape",
                    iconColor: .inkSoft,
                    label: "App 設定",
                    hint: "通知、深色模式、字體大小"
                ) { /* TODO */ }
            }
        }
    }

    // MARK: - Footer

    private var buildStamp: some View {
        Text("師傅號 · v2.0 · build 2026.05.20")
            .font(AppFont.mono(11))
            .foregroundStyle(Color.inkFaint)
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
    }

    // MARK: - Helpers

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.appBorder)
            .frame(height: 1)
            .padding(.leading, 48)      // 對齊 icon 後
    }

    static func currencyLabel(_ code: String) -> String {
        switch code {
        case "TWD": "NT$ 新台幣"
        case "VND": "₫ 越南盾"
        case "IDR": "Rp 印尼盾"
        case "USD": "US$ 美元"
        case "MYR": "RM 馬幣"
        case "PHP": "₱ 菲律賓比索"
        default:    code
        }
    }

    static func languageLabel(_ code: String) -> String {
        switch code {
        case "zh-Hant": "繁體中文"
        case "zh-Hans": "簡體中文"
        case "en":      "English"
        case "vi":      "Tiếng Việt"
        case "id":      "Bahasa Indonesia"
        default:        code
        }
    }

    static func taxRegion(_ currency: String) -> String {
        switch currency {
        case "TWD": "台灣營業稅"
        case "VND": "越南 VAT"
        case "IDR": "印尼 PPN"
        case "MYR": "馬來 SST"
        case "PHP": "菲律賓 VAT"
        default:    "—"
        }
    }
}

#Preview("未訂閱") {
    NavigationStack {
        SettingsScreen()
    }
    .environment(AppSettings())
    .modelContainer(PreviewData.container)
}

#Preview("PRO") {
    let s = AppSettings()
    s.isPro = true
    s.masterName = "陳師傅"
    return NavigationStack {
        SettingsScreen()
    }
    .environment(s)
    .modelContainer(PreviewData.container)
}
