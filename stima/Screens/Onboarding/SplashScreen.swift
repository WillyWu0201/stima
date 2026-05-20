import SwiftUI

/// 畫面 01 · 歡迎 / Splash
/// 入口畫面，沒有 back 按鈕，frictionless 不收集任何資訊。
struct SplashScreen: View {
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 版本 chip
            Text("師傅號 · v2.0")
                .font(AppFont.sans(12, weight: .semibold))
                .foregroundStyle(Color.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.accent.opacity(0.12), in: Capsule())
                .padding(.bottom, 22)

            // Hero
            Text("報價收款，\n一支手機\n全包了。")
                .font(AppFont.sans(40, weight: .heavy))
                .foregroundStyle(Color.ink)
                .lineSpacing(2)
                .kerning(-0.8)
                .padding(.bottom, 16)

            // Subhead
            Text("工地老闆，幾步就上手。算項目、看數字、追收款，都在這。")
                .font(AppFont.sans(16))
                .foregroundStyle(Color.inkSoft)
                .lineSpacing(4)
                .frame(maxWidth: 280, alignment: .leading)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgPaper)
        .safeAreaInset(edge: .bottom) {
            BottomCTA(withBackground: false) {
                PrimaryButton("開工", systemImage: "arrow.right") {
                    onNext()
                }
            } above: {
                Text("不用先註冊，按下去就可以開始試。")
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkFaint)
                    .frame(maxWidth: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SplashScreen(onNext: { })
    }
}
