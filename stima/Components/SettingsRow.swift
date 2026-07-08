import SwiftUI

/// 設定畫面的列（純展示）：左 icon + 中間 label/hint + 右側 chevron 或 value/badge。
/// 多個 row 包在同一張 padding=false 的 AppCard 內，row 之間用內部 divider 分。
/// 點擊行為由外層 Button 或 NavigationLink 處理，方便導頁也方便做 closure action。
///
/// 用法：
///   Button { ... } label: {
///       SettingsRow(systemImage: "globe", label: "語言", rightValue: "繁體中文")
///   }
///   .buttonStyle(.plain)
///
///   NavigationLink { ContactsScreen() } label: {
///       SettingsRow(systemImage: "person", label: "客戶簿", hint: "所有客戶與聯絡資料")
///   }
///   .buttonStyle(.plain)
struct SettingsRow: View {
    let systemImage: String
    var iconColor: Color = .accent
    let label: String
    var hint: String? = nil
    var rightValue: String? = nil       // 右側顯示的數值（國際化 row）
    var proLabel: Bool = false           // 是否顯示 PRO badge
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(iconColor)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(LocalizedStringKey(label))
                        .font(AppFont.sans(15, weight: .semibold))
                        .foregroundStyle(Color.ink)
                    if proLabel {
                        Text("PRO")
                            .font(AppFont.mono(10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.accent, in: Capsule())
                    }
                }
                if let hint {
                    Text(hint)
                        .font(AppFont.sans(12))
                        .foregroundStyle(Color.inkSoft)
                }
            }
            Spacer(minLength: 8)

            if let rightValue {
                Text(rightValue)
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSoft)
            }
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.inkFaint)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 0) {
        AppCard(padded: false) {
            VStack(spacing: 0) {
                SettingsRow(systemImage: "person", iconColor: .accent,
                            label: "客戶簿", hint: "所有客戶與聯絡資料")
                Divider().background(Color.appBorder)
                SettingsRow(systemImage: "doc.text", iconColor: .accent,
                            label: "報價單模板（PDF）",
                            hint: "Logo、抬頭、付款條件、印章",
                            proLabel: true)
            }
        }

        Spacer().frame(height: 16)

        AppCard(padded: false) {
            VStack(spacing: 0) {
                SettingsRow(systemImage: "dollarsign.circle", iconColor: .cool,
                            label: "貨幣", rightValue: "NT$ (新台幣)")
                Divider().background(Color.appBorder)
                SettingsRow(systemImage: "globe", iconColor: .cool,
                            label: "語言", rightValue: "繁體中文")
            }
        }
    }
    .padding()
    .background(Color.bgPaper)
}
