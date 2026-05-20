import SwiftUI

/// 標準卡片容器：白色底、邊框、圓角。
///
/// 用法：
///   AppCard {
///       Text("內容")
///   }
///
///   AppCard(accent: true) {
///       Text("深色 hero 卡")
///   }
struct AppCard<Content: View>: View {
    var accent: Bool = false
    var padded: Bool = true
    var onTap: (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        let card = content()
            .padding(padded ? Spacing.card : 0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accent ? Color.accentSurface : Color.appSurface)
            .foregroundStyle(accent ? Color.accentSurfaceInk : Color.ink)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(accent ? Color.clear : Color.appBorder, lineWidth: 1)
            )

        if let onTap {
            Button(action: onTap) { card }
                .buttonStyle(.plain)
        } else {
            card
        }
    }
}

#Preview {
    VStack(spacing: Spacing.cardGap) {
        AppCard {
            Text("普通卡片")
                .font(AppFont.sans(AppFont.body))
        }

        AppCard(accent: true) {
            VStack(alignment: .leading, spacing: 6) {
                Text("總計")
                    .font(AppFont.sans(AppFont.sublabel))
                    .foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
                Text("$285,000")
                    .font(AppFont.mono(28, weight: .bold))
                    .foregroundStyle(Color.accent2)
            }
        }

        AppCard(onTap: { print("tapped") }) {
            Text("可點擊卡片")
                .font(AppFont.sans(AppFont.body))
        }
    }
    .padding(Spacing.screenH)
    .background(Color.bgPaper)
}
