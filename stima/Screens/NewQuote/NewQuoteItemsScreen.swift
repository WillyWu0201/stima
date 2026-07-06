import SwiftUI

/// 畫面 05 · 加項目（採推薦的 sheet 版 05c/05d）
/// 主畫面只顯示目前項目；「+ 加項目」按鈕召喚 ItemPickerSheet 從底部彈出。
struct NewQuoteItemsScreen: View {
    @Bindable var draft: NewQuoteDraft
    let onNext: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Environment(TutorialState.self) private var tutorial
    @State private var pickerOpen = false
    @State private var toastText: String? = nil
    @State private var coachDone = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 8) {
                        if draft.items.isEmpty {
                            emptyState
                        } else {
                            ForEach($draft.items) { $item in
                                EditableItemRow(item: $item) {
                                    remove(item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.bgPaper)

            if let toastText {
                toast(text: toastText)
                    .padding(.top, 110)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) { bottomBar }
        .sheet(isPresented: $pickerOpen) {
            ItemPickerSheet(
                categories: settings.categories,
                addedCounts: addedCounts
            ) { item in
                draft.items.append(item)
                showToast(item.name)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .coachMark(active: tutorial.coachingActive && !coachDone,
                   target: "items",
                   text: "點「加項目」，從清單挑你要做的工，數量價錢都能改。") {
            coachDone = true
        }
    }

    // MARK: - Toast

    private func toast(text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
            Text("已加 「\(text)」")
                .font(AppFont.sans(13, weight: .semibold))
        }
        .foregroundStyle(Color.bgPaper)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.ink, in: Capsule())
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
    }

    private func showToast(_ name: String) {
        withAnimation(.easeOut(duration: 0.2)) {
            toastText = name
        }
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeIn(duration: 0.2)) {
                toastText = nil
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        AppHeader(
            title: "加項目",
            subtitle: "新增報價單 · 2 / 3",
            onBack: { dismiss() }
        ) {
            Text("已加 \(draft.items.count)")
                .font(AppFont.mono(12))
                .foregroundStyle(Color.inkSoft)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .strokeBorder(Color.accent, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .background(Circle().fill(Color.surfaceAlt))
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.accent)
            }
            .frame(width: 64, height: 64)
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("還沒加項目")
                    .font(AppFont.sans(16, weight: .semibold))
                    .foregroundStyle(Color.ink)
                Text("點下方的「+ 加項目」開始")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSoft)
            }
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }

    private var bottomBar: some View {
        BottomCTA {
            HStack(spacing: 8) {
                addButton
                    .coachAnchor("items")
                PrimaryButton("下一步", systemImage: "arrow.right") {
                    onNext()
                }
                .disabled(draft.items.isEmpty)
            }
        } above: {
            HStack {
                Text("目前小計")
                    .font(AppFont.sans(AppFont.sublabel))
                    .foregroundStyle(Color.inkSoft)
                Spacer()
                Money(draft.subtotal, size: 20, color: .accent2)
            }
        }
    }

    private var addButton: some View {
        Button {
            pickerOpen = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("加項目")
                    .font(AppFont.sans(15, weight: .semibold))
            }
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassNeutral()
        }
        .buttonStyle(.plain)
        .fixedSize()
    }

    // MARK: - Mutations

    private func remove(_ item: NewQuoteDraft.Item) {
        draft.items.removeAll { $0.id == item.id }
    }

    /// draft 內每個 name 出現幾次 — 給 picker 顯示「✓ 已加 ×N」用。
    private var addedCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for item in draft.items {
            counts[item.name, default: 0] += 1
        }
        return counts
    }
}

// MARK: - Inline editable row

/// 已加項目的列，可內嵌修改 qty 與 price。
private struct EditableItemRow: View {
    @Binding var item: NewQuoteDraft.Item
    let onDelete: () -> Void

    var body: some View {
        AppCard(padded: false) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundStyle(Color.ink)

                    HStack(spacing: 6) {
                        miniNumberField(
                            value: Binding(
                                get: { String(Int(item.qty)) },
                                set: { item.qty = Double($0.filter(\.isNumber)) ?? 0 }
                            ),
                            width: 44
                        )
                        Text("\(item.unit) × $")
                            .font(AppFont.sans(13))
                            .foregroundStyle(Color.inkSoft)
                            .fixedSize()
                        miniNumberField(
                            value: Binding(
                                get: { String(item.price) },
                                set: { item.price = Int($0.filter(\.isNumber)) ?? 0 }
                            ),
                            width: 72
                        )
                    }
                }
                Spacer(minLength: 8)
                Money(item.subtotal, size: 16, color: .ink)
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.inkFaint)
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("移除")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func miniNumberField(value: Binding<String>, width: CGFloat) -> some View {
        TextField("", text: value)
            .multilineTextAlignment(.trailing)
            .font(AppFont.mono(13))
            .foregroundStyle(Color.ink)
            .keyboardType(.numberPad)
            .frame(width: width)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.small, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1)
            )
    }
}

#Preview("空狀態") {
    NavigationStack {
        NewQuoteItemsScreen(draft: NewQuoteDraft(), onNext: {})
    }
    .environment(AppSettings())
    .environment(TutorialState())
}

#Preview("已加幾項") {
    let draft = NewQuoteDraft()
    draft.items = [
        .init(name: "拆除磁磚", unit: "坪", qty: 10, price: 1800),
        .init(name: "油漆批土", unit: "坪", qty: 25, price: 850),
    ]
    return NavigationStack {
        NewQuoteItemsScreen(draft: draft, onNext: {})
    }
    .environment(AppSettings())
    .environment(TutorialState())
}
