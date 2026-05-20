import SwiftUI

/// 自訂項目表單（出現在 ItemPickerSheet 的「自訂」tab 內）。
/// 填完按「加進去」會 callback 給 sheet，sheet 不關方便批次加。
struct CustomItemForm: View {
    @Binding var draft: CustomDraft
    let categories: [String]    // 不含「常用」
    let onAdd: (NewQuoteDraft.Item) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            hintCard
            nameField
            categoryField
            unitField
            priceQtyRow
            previewCard
            addButton
        }
    }

    // MARK: - 區塊

    private var hintCard: some View {
        Text("加進你的項目庫，下次直接挑就行。")
            .font(AppFont.sans(12))
            .foregroundStyle(Color.inkSoft)
            .lineSpacing(3)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surfaceAlt,
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.appBorder)
            )
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("項目名稱")
            AppTextField(text: $draft.name, placeholder: "例：拆冷氣、磨地板、外牆貼磚")
        }
    }

    private var categoryField: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("歸到哪個分類")
            FlowRow(spacing: 4) {
                ForEach(categories, id: \.self) { cat in
                    chip(label: cat,
                         active: draft.category == cat,
                         style: .ink) {
                        draft.category = cat
                    }
                }
            }
            Text("所有新項目都會自動進「常用」，加上分類後也會出現在那個分頁。")
                .font(AppFont.sans(11))
                .foregroundStyle(Color.inkFaint)
                .padding(.top, 4)
        }
    }

    private var unitField: some View {
        VStack(alignment: .leading, spacing: 6) {
            label("單位")
            FlowRow(spacing: 4) {
                ForEach(ItemLibrary.units, id: \.self) { unit in
                    chip(label: unit,
                         active: draft.unit == unit,
                         style: .ink) {
                        draft.unit = unit
                    }
                }
            }
        }
    }

    private var priceQtyRow: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                label("單價 (NT$)")
                AppTextField(text: $draft.price, placeholder: "0")
                    .keyboardType(.numberPad)
            }
            VStack(alignment: .leading, spacing: 6) {
                label("數量")
                AppTextField(text: $draft.qty, placeholder: "1")
                    .keyboardType(.decimalPad)
            }
            .frame(width: 110)
        }
    }

    private var previewCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(draft.name.isEmpty ? "— 項目名稱 —" : draft.name)
                    .font(AppFont.sans(14, weight: .semibold))
                    .foregroundStyle(draft.name.isEmpty ? Color.inkFaint : Color.ink)
                HStack(spacing: 0) {
                    Text("\(Int(draft.qtyNumber)) \(draft.unit) × $\(draft.priceNumber.formatted())")
                    if let cat = draft.category {
                        Text("  ·  \(cat)")
                            .foregroundStyle(Color.accent)
                    }
                }
                .font(AppFont.mono(11))
                .foregroundStyle(Color.inkSoft)
            }
            Spacer()
            Money(Int(draft.qtyNumber) * draft.priceNumber,
                  size: 15,
                  color: draft.canSubmit ? .accent : .inkFaint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.appSurface,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(Color.accent)
        )
    }

    private var addButton: some View {
        Button {
            submit()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("加進去")
                    .font(AppFont.sans(15, weight: .semibold))
            }
            .foregroundStyle(draft.canSubmit ? Color.accent : Color.inkFaint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(draft.canSubmit ? Color.accent : Color.appBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(!draft.canSubmit)
    }

    // MARK: - Helpers

    private func submit() {
        guard draft.canSubmit else { return }
        onAdd(.init(
            name: draft.name.trimmingCharacters(in: .whitespaces),
            unit: draft.unit,
            qty: draft.qtyNumber,
            price: draft.priceNumber
        ))
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(AppFont.sans(12, weight: .semibold))
            .foregroundStyle(Color.inkSoft)
    }

    // MARK: - Chip 樣式

    private enum ChipStyle { case ink, accent }

    private func chip(label: String, active: Bool, style: ChipStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.sans(13, weight: .semibold))
                .foregroundStyle(activeFg(active: active, style: style))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(activeBg(active: active, style: style), in: Capsule())
                .overlay(
                    Capsule().strokeBorder(borderColor(active: active, style: style), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func activeFg(active: Bool, style: ChipStyle) -> Color {
        if active { return .white }
        return .ink
    }
    private func activeBg(active: Bool, style: ChipStyle) -> Color {
        guard active else { return .appSurface }
        return style == .ink ? .ink : .accent
    }
    private func borderColor(active: Bool, style: ChipStyle) -> Color {
        if active { return activeBg(active: true, style: style) }
        return .appBorder
    }
}

// MARK: - 簡易 FlowLayout：自動換行排列 chip

struct FlowRow: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = arrange(in: maxWidth, subviews: subviews)
        let totalHeight = rows.reduce(0) { $0 + $1.height } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrange(in: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for (index, size) in row.items {
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> [(items: [(index: Int, size: CGSize)], height: CGFloat)] {
        var rows: [(items: [(index: Int, size: CGSize)], height: CGFloat)] = []
        var current: [(index: Int, size: CGSize)] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for (i, sv) in subviews.enumerated() {
            let size = sv.sizeThatFits(.unspecified)
            let needed = current.isEmpty ? size.width : currentWidth + spacing + size.width
            if needed > maxWidth, !current.isEmpty {
                rows.append((current, currentHeight))
                current = []
                currentWidth = 0
                currentHeight = 0
            }
            current.append((i, size))
            currentWidth = current.isEmpty ? size.width : currentWidth + (current.count == 1 ? 0 : spacing) + size.width
            currentHeight = max(currentHeight, size.height)
        }
        if !current.isEmpty {
            rows.append((current, currentHeight))
        }
        return rows
    }
}

#Preview {
    @Previewable @State var draft = CustomDraft()
    ScrollView {
        CustomItemForm(
            draft: $draft,
            categories: ["拆除", "水電", "泥作", "木作"]
        ) { item in
            print("加入:", item.name, item.price)
        }
        .padding()
    }
    .background(Color.appSurface)
}
