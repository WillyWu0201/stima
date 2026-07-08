import SwiftUI

/// 卡片底部的 quick action 按鈕（撥打 / 導航 / 新報價 等）。
/// 多個並排佔滿寬度。`primary = true` 用橙色填底白字。
///
/// 用法：
///   HStack(spacing: 6) {
///       QuickActionButton(systemImage: "phone", label: "撥打") { ... }
///       QuickActionButton(systemImage: "mappin", label: "導航") { ... }
///       QuickActionButton(systemImage: "plus", label: "新報價", primary: true) { ... }
///   }
struct QuickActionButton: View {
    let systemImage: String
    let label: String
    var primary: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                Text(LocalizedStringKey(label))
                    .font(AppFont.sans(12, weight: .semibold))
            }
            .foregroundStyle(primary ? .white : Color.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(
                primary ? Color.accent : Color.clear,
                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(primary ? Color.clear : Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 6) {
        QuickActionButton(systemImage: "phone", label: "撥打") {}
        QuickActionButton(systemImage: "mappin", label: "導航") {}
        QuickActionButton(systemImage: "plus", label: "新報價", primary: true) {}
    }
    .padding()
    .background(Color.bgPaper)
}
