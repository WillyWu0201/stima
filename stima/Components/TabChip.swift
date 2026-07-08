import SwiftUI

/// 篩選用的 pill 按鈕。active 時用 accent 填底 + 白字（不分 dark mode 都一樣）。
///
/// 用法：
///   TabChip(label: "全部", count: 6, isActive: true) { ... }
///   TabChip(label: "2026", count: 3, isFolder: true) { ... }
struct TabChip: View {
    let label: String
    let count: Int
    var isActive: Bool = false
    var isFolder: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if isFolder {
                    Image(systemName: "folder")
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(LocalizedStringKey(label))
                    .font(AppFont.sans(13, weight: .semibold))
                Text("\(count)")
                    .font(AppFont.sans(11, weight: .semibold))
                    .foregroundStyle(isActive ? Color.white : Color.inkSoft)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        isActive
                            ? Color.white.opacity(0.22)
                            : Color.bgSoft,
                        in: Capsule()
                    )
            }
            .foregroundStyle(isActive ? Color.white : Color.ink)
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(
                isActive ? Color.accent : Color.appSurface,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isActive ? Color.accent : Color.appBorder,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .fixedSize()
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            TabChip(label: "全部",   count: 6, isActive: true)  { }
            TabChip(label: "進行中", count: 2)                  { }
            TabChip(label: "已完工", count: 1)                  { }
            TabChip(label: "已收款", count: 2)                  { }
            TabChip(label: "2026",   count: 3, isFolder: true)  { }
            TabChip(label: "老客戶", count: 2, isFolder: true)  { }
        }
        .padding()
    }
    .background(Color.bgPaper)
}
