import SwiftUI

/// 加項目用的 bottom sheet（設計稿 05c/05d）。
/// 內含「自訂」+ 內建分類 tab，可從 library 挑或自己加一筆。
/// 加完 sheet 不關，方便批次加；主畫面會顯示「已加 OOO」toast。
struct ItemPickerSheet: View {
    let categories: [String]
    /// 目前 draft 內已加項目，依 name → 加過幾次。Picker 用來顯示「已加 ×N」marker。
    let addedCounts: [String: Int]
    let onAdd: (NewQuoteDraft.Item) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: String
    @State private var customDraft = CustomDraft()

    init(categories: [String],
         addedCounts: [String: Int] = [:],
         onAdd: @escaping (NewQuoteDraft.Item) -> Void) {
        self.categories = categories
        self.addedCounts = addedCounts
        self.onAdd = onAdd
        // 預設 「常用」
        _selectedTab = State(initialValue: "常用")
    }

    private var allTabs: [String] { ["自訂"] + categories }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabRow
                content
            }
            .background(Color.appSurface)
            .navigationTitle("挑項目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .tint(.accent)
    }

    // MARK: - Tabs

    private var tabRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(allTabs, id: \.self) { tab in
                    PickerTab(
                        label: tab,
                        isCustom: tab == "自訂",
                        isActive: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if selectedTab == "自訂" {
            ScrollView {
                CustomItemForm(
                    draft: $customDraft,
                    categories: categories.filter { $0 != "常用" }
                ) { item in
                    onAdd(item)
                    customDraft = CustomDraft()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(ItemLibrary.entries(in: selectedTab)) { entry in
                        LibraryEntryRow(entry: entry,
                                        addedCount: addedCounts[entry.name, default: 0]) {
                            onAdd(.init(name: entry.name,
                                        unit: entry.unit,
                                        qty: 1,
                                        price: entry.lastPrice))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 28)
            }
        }
    }
}

// MARK: - 自訂項目暫存

struct CustomDraft {
    var name: String = ""
    var category: String? = nil
    var unit: String = "坪"
    var price: String = ""
    var qty: String = "1"
    var cost: String = ""

    var qtyNumber: Double { Double(qty) ?? 1 }
    var priceNumber: Int { Int(price) ?? 0 }
    var costNumber: Int { Int(cost) ?? 0 }
    var canSubmit: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && priceNumber > 0 }
}

// MARK: - Library entry row

private struct LibraryEntryRow: View {
    let entry: ItemLibrary.Entry
    var addedCount: Int = 0
    let onAdd: () -> Void

    @Environment(\.currencySymbol) private var currencySymbol

    private var alreadyAdded: Bool { addedCount > 0 }

    var body: some View {
        Button(action: onAdd) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(entry.name)
                            .font(AppFont.sans(15, weight: .semibold))
                            .foregroundStyle(Color.ink)
                        if alreadyAdded {
                            Text("✓ 已加 ×\(addedCount)")
                                .font(AppFont.sans(10, weight: .bold))
                                .foregroundStyle(Color.accent)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(Color.accent.opacity(0.14), in: Capsule())
                        }
                    }
                    HStack(spacing: 0) {
                        Text("上次 \(currencySymbol)\(entry.lastPrice.formatted()) / \(entry.unit)")
                        if let n = entry.usedCount {
                            Text(" · 用過 \(n) 次")
                        }
                    }
                    .font(AppFont.mono(11))
                    .foregroundStyle(Color.inkSoft)
                }
                Spacer(minLength: 8)
                ZStack {
                    Circle()
                        .fill(alreadyAdded ? Color.accent.opacity(0.4) : Color.accent)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfaceAlt,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(alreadyAdded ? Color.accent.opacity(0.4) : Color.appBorder,
                                  lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Picker tab chip（自訂用 accent 風格，其他用 ink 風格）

private struct PickerTab: View {
    let label: String
    let isCustom: Bool
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if isCustom {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                }
                Text(label)
                    .font(AppFont.sans(13, weight: .semibold))
            }
            .foregroundStyle(fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(bg, in: Capsule())
            .overlay(
                Capsule().strokeBorder(border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .fixedSize()
    }

    private var fg: Color {
        if isActive { return .white }
        return isCustom ? .accent : .ink
    }
    private var bg: Color {
        if !isActive { return .clear }
        return isCustom ? .accent : .ink
    }
    private var border: Color {
        if isActive { return bg }
        return isCustom ? .accent : .appBorder
    }
}

#Preview {
    Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ItemPickerSheet(
                categories: ["常用", "拆除", "水電", "泥作", "木作"]
            ) { item in
                print("加入:", item.name)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
}
