import SwiftUI

/// 頂部標題列。設計稿幾乎所有畫面都有，多數是 accent（深色）版本。
///
/// 用法：
///   AppHeader(title: "我的報價單", subtitle: "歡迎，陳師傅", accent: true) {
///       Button { } label: { Image(systemName: "plus") }
///   }
struct AppHeader<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var accent: Bool = false
    var onBack: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        let fg = accent ? Color.accentSurfaceInk : Color.ink
        let subFg = accent ? Color.onAccentMuted : Color.inkSoft

        HStack(alignment: .top, spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(fg)
                        .frame(width: 28, height: 28, alignment: .leading)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let subtitle {
                    Text(subtitle)
                        .font(AppFont.sans(AppFont.sublabel))
                        .foregroundStyle(subFg)
                }
                Text(title)
                    .font(AppFont.sans(AppFont.navTitle, weight: .bold))
                    .foregroundStyle(fg)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailing()
                .foregroundStyle(fg)
        }
        .padding(.horizontal, Spacing.screenH)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(accent ? Color.accentSurface : Color.bgPaper)
    }
}

extension AppHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, accent: Bool = false, onBack: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accent = accent
        self.onBack = onBack
        self.trailing = { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 0) {
        AppHeader(title: "我的報價單", subtitle: "歡迎，陳師傅", accent: true) {
            Button { } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .regular))
            }
        }

        AppHeader(title: "報價單模板", subtitle: "設定", onBack: { }) {
            Button("預覽") { }
                .font(AppFont.sans(AppFont.body, weight: .semibold))
                .foregroundStyle(Color.accent)
        }

        AppHeader(title: "客戶簿")

        Spacer()
    }
    .background(Color.bgPaper)
}
