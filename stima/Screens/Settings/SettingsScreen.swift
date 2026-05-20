import SwiftUI
import SwiftData

/// 畫面 11 · 設定
/// Top-level tab，把 AppSettings 大多數欄位接到 UI。
/// 項目分類管理 / 自訂項目管理留在下個 commit。
struct SettingsScreen: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CustomItem.name) private var customItems: [CustomItem]

    /// 不可刪除的內建分類（仍可編輯名稱，但不會出現垃圾桶按鈕）。
    private static let fixedCategories: Set<String> = ["拆除", "水電", "泥作", "木作", "油漆"]

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
                    categoriesCard

                    SectionTitle("我的自訂項目（\(customItems.count)）")
                    customItemsCard

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
                NavigationLink {
                    ContactsScreen()
                } label: {
                    SettingsRow(
                        systemImage: "person",
                        iconColor: .accent,
                        label: "客戶簿",
                        hint: "所有客戶與聯絡資料"
                    )
                }
                .buttonStyle(.plain)

                rowDivider

                Button {
                    // TODO: 推進 PDFTemplateScreen
                } label: {
                    SettingsRow(
                        systemImage: "doc.text",
                        iconColor: .accent,
                        label: "報價單模板（PDF）",
                        hint: "Logo、抬頭、付款條件、印章",
                        proLabel: !settings.isPro
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 項目分類

    private var categoriesCard: some View {
        @Bindable var settings = settings
        // 顯示分類時排除「常用」（系統 tag、永遠在最上）
        let editable = settings.categories.filter { $0 != "常用" }
        return AppCard(padded: false) {
            VStack(spacing: 0) {
                ForEach(Array(editable.enumerated()), id: \.element) { index, cat in
                    CategoryRow(
                        name: cat,
                        isFixed: Self.fixedCategories.contains(cat),
                        onRename: { newName in renameCategory(cat, to: newName) },
                        onDelete: { deleteCategory(cat) }
                    )
                    if index < editable.count - 1 {
                        Rectangle()
                            .fill(Color.appBorder)
                            .frame(height: 1)
                    }
                }
                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1)
                NewCategoryInput { addCategory($0) }
            }
        }
    }

    private func renameCategory(_ old: String, to new: String) {
        let trimmed = new.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != old, !settings.categories.contains(trimmed) else { return }
        settings.categories = settings.categories.map { $0 == old ? trimmed : $0 }
    }

    private func deleteCategory(_ cat: String) {
        settings.categories.removeAll { $0 == cat }
    }

    private func addCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !settings.categories.contains(trimmed) else { return }
        settings.categories.append(trimmed)
    }

    // MARK: - 自訂項目

    @ViewBuilder
    private var customItemsCard: some View {
        if customItems.isEmpty {
            AppCard {
                Text("還沒加過自訂項目。\n在「新增報價單 → 加項目 → + 自訂」就能加。")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 4)
            }
        } else {
            AppCard(padded: false) {
                VStack(spacing: 0) {
                    ForEach(Array(customItems.enumerated()), id: \.element.id) { index, item in
                        CustomItemRow(item: item) {
                            modelContext.delete(item)
                        }
                        if index < customItems.count - 1 {
                            Rectangle()
                                .fill(Color.appBorder)
                                .frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 國際化

    private var internationalCard: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                Button { /* TODO: 切換貨幣 */ } label: {
                    SettingsRow(
                        systemImage: "dollarsign.circle",
                        iconColor: .cool,
                        label: "貨幣",
                        rightValue: Self.currencyLabel(settings.currency)
                    )
                }
                .buttonStyle(.plain)

                rowDivider

                Button { /* TODO: 切換語言 */ } label: {
                    SettingsRow(
                        systemImage: "globe",
                        iconColor: .cool,
                        label: "語言",
                        rightValue: Self.languageLabel(settings.language)
                    )
                }
                .buttonStyle(.plain)

                rowDivider

                Button { /* TODO: 切換稅制 */ } label: {
                    SettingsRow(
                        systemImage: "percent",
                        iconColor: .cool,
                        label: "稅制",
                        rightValue: "\(Int(settings.taxRate))% · \(Self.taxRegion(settings.currency))"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 其他

    private var miscCard: some View {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                Button { /* TODO: 匯出 */ } label: {
                    SettingsRow(
                        systemImage: "square.and.arrow.up",
                        iconColor: .inkSoft,
                        label: "匯出全部資料",
                        hint: "備份成 Excel / CSV"
                    )
                }
                .buttonStyle(.plain)

                rowDivider

                Button { /* TODO: App 設定 */ } label: {
                    SettingsRow(
                        systemImage: "gearshape",
                        iconColor: .inkSoft,
                        label: "App 設定",
                        hint: "通知、深色模式、字體大小"
                    )
                }
                .buttonStyle(.plain)
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

// MARK: - 分類列

private struct CategoryRow: View {
    let name: String
    let isFixed: Bool
    let onRename: (String) -> Void
    let onDelete: () -> Void

    @State private var isEditing = false
    @State private var draftName = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.accent)
                .frame(width: 6, height: 6)

            if isEditing {
                TextField("", text: $draftName)
                    .font(AppFont.sans(15))
                    .foregroundStyle(Color.ink)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { commitRename() }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.surfaceAlt,
                                in: RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.accent, lineWidth: 1.5)
                    )
            } else {
                Text(name)
                    .font(AppFont.sans(15, weight: .medium))
                    .foregroundStyle(Color.ink)
            }

            Spacer()

            Button {
                if isEditing {
                    commitRename()
                } else {
                    draftName = name
                    isEditing = true
                    focused = true
                }
            } label: {
                Text(isEditing ? "完成" : "編輯")
                    .font(AppFont.sans(12, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                    .padding(4)
            }
            .buttonStyle(.plain)

            if !isFixed && !isEditing {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.accent)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("刪除分類")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func commitRename() {
        let v = draftName.trimmingCharacters(in: .whitespaces)
        if !v.isEmpty && v != name {
            onRename(v)
        }
        isEditing = false
        focused = false
    }
}

// MARK: - 新增分類輸入列

private struct NewCategoryInput: View {
    let onAdd: (String) -> Void
    @State private var input = ""

    var body: some View {
        HStack(spacing: 8) {
            TextField("加新分類，例：清潔、家具", text: $input)
                .font(AppFont.sans(14))
                .foregroundStyle(Color.ink)
                .submitLabel(.done)
                .onSubmit { commit() }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.appSurface,
                            in: RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.appBorder, lineWidth: 1)
                )

            Button(action: commit) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("加")
                        .font(AppFont.sans(13, weight: .semibold))
                }
                .foregroundStyle(input.isEmpty ? Color.inkFaint : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(input.isEmpty ? Color.bgSoft : Color.accent,
                            in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .disabled(input.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.surfaceAlt)
    }

    private func commit() {
        let v = input.trimmingCharacters(in: .whitespaces)
        guard !v.isEmpty else { return }
        onAdd(v)
        input = ""
    }
}

// MARK: - 自訂項目列

private struct CustomItemRow: View {
    let item: CustomItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.ink)
                HStack(spacing: 6) {
                    Text("$\(item.price.formatted()) / \(item.unit)")
                        .font(AppFont.mono(12))
                        .foregroundStyle(Color.inkSoft)
                    Text(item.category)
                        .font(AppFont.sans(11, weight: .semibold))
                        .foregroundStyle(Color.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.accent.opacity(0.12), in: Capsule())
                }
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accent)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("刪除")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
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
