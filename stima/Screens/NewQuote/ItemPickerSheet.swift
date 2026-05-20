import SwiftUI

/// 加項目用的 bottom sheet（設計稿 05c/05d）。
/// 內含「自訂」+ 內建分類 tab，可從 library 挑或自己加一筆。
/// 加完 sheet 不關，方便批次加；主畫面會顯示「已加 OOO」toast。
struct ItemPickerSheet: View {
    let categories: [String]
    let onAdd: (NewQuoteDraft.Item) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: String
    @State private var customDraft = CustomDraft()

    init(categories: [String], onAdd: @escaping (NewQuoteDraft.Item) -> Void) {
        self.categories = categories
        self.onAdd = onAdd
        // 預設 「常用」
        _selectedTab = State(initialValue: "常用")
    }

    private var allTabs: [String] { ["自訂"] + categories }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            tabRow
            content
        }
        .background(Color.appSurface)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text("挑項目，或自己加")
                .font(AppFont.sans(18, weight: .bold))
                .foregroundStyle(Color.ink)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.inkSoft)
                    .frame(width: 32, height: 32)
                    .background(Color.bgSoft, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("關閉")
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 14)
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
                        LibraryEntryRow(entry: entry) {
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

    var qtyNumber: Double { Double(qty) ?? 1 }
    var priceNumber: Int { Int(price) ?? 0 }
    var canSubmit: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && priceNumber > 0 }
}

// MARK: - Library entry row

private struct LibraryEntryRow: View {
    let entry: ItemLibrary.Entry
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    HStack(spacing: 0) {
                        Text("上次 $\(entry.lastPrice.formatted()) / \(entry.unit)")
                        if let n = entry.usedCount {
                            Text(" · 用過 \(n) 次")
                        }
                    }
                    .font(AppFont.mono(11))
                    .foregroundStyle(Color.inkSoft)
                }
                Spacer(minLength: 8)
                ZStack {
                    Circle().fill(Color.accent)
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
                    .strokeBorder(Color.appBorder, lineWidth: 1)
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
