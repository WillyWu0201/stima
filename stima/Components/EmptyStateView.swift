import SwiftUI

/// 統一的空狀態：圓形 icon + 標題 + 說明 + 可選的主要行動按鈕。
/// 取代各畫面散落的 emoji-only 空狀態。
///
/// 用法：
///   EmptyStateView(systemImage: "doc.text", title: "還沒有報價單")
///
///   EmptyStateView(systemImage: "doc.text.magnifyingglass",
///                  title: "還沒有報價單",
///                  message: "建好第一張，客戶、項目、收款都從這裡開始。") {
///       PrimaryButton("建立第一張報價單", systemImage: "plus") { ... }
///   }
struct EmptyStateView<Action: View>: View {
    let systemImage: String
    let title: LocalizedStringKey
    var message: LocalizedStringKey? = nil
    @ViewBuilder var action: () -> Action

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.surfaceAlt)
                Image(systemName: systemImage)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.accent)
            }
            .frame(width: 72, height: 72)
            .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(title)
                    .font(AppFont.sans(16, weight: .semibold))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(.center)
                if let message {
                    Text(message)
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkSoft)
                        .multilineTextAlignment(.center)
                }
            }

            action()
                .frame(maxWidth: 260)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .padding(.horizontal, Spacing.screenH)
    }
}

extension EmptyStateView where Action == EmptyView {
    init(systemImage: String, title: LocalizedStringKey, message: LocalizedStringKey? = nil) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.action = { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 0) {
        EmptyStateView(
            systemImage: "doc.text.magnifyingglass",
            title: "還沒有報價單",
            message: "建好第一張，客戶、項目、收款都從這裡開始。"
        ) {
            PrimaryButton("建立第一張報價單", systemImage: "plus") { }
        }

        EmptyStateView(systemImage: "magnifyingglass", title: "找不到符合的報價單")
    }
    .background(Color.bgPaper)
}
