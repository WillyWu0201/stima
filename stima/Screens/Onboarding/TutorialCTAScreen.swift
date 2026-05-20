import SwiftUI

/// 畫面 03 · 教學 CTA
/// 邀請使用者試做第一張報價單。完成或跳過後 onboarding 結束。
/// TODO: 「來試一張看看」應該觸發 tutorial coaching mode；目前兩個按鈕行為一樣。
struct TutorialCTAScreen: View {
    let onStart: () -> Void
    let onSkip: () -> Void
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    private var displayName: String {
        let name = settings.masterName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return "師傅" }
        return name.hasSuffix("師傅") ? name : "\(name)師傅"
    }

    var body: some View {
        VStack(spacing: 0) {
            BackButton(action: { dismiss() })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
                .padding(.top, 12)

            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                Text("嗨，\(displayName) 👋")
                    .font(AppFont.sans(15, weight: .semibold))
                    .foregroundStyle(Color.accent)
                    .padding(.bottom, 8)

                Text("我們來試做\n第一張報價單。")
                    .font(AppFont.sans(32, weight: .heavy))
                    .foregroundStyle(Color.ink)
                    .lineSpacing(2)
                    .kerning(-0.6)
                    .padding(.bottom, 14)

                Text("過程中我會在旁邊指一下重點。\n放心，假的，做壞了也沒事。")
                    .font(AppFont.sans(15))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(4)
                    .padding(.bottom, 20)

                stepChip
            }
            .padding(.horizontal, 22)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .background(Color.bgPaper)
        .safeAreaInset(edge: .bottom) {
            BottomCTA(withBackground: false) {
                PrimaryButton("來試一張看看", systemImage: "hammer.fill") {
                    onStart()
                }
            } above: {
                Button { onSkip() } label: {
                    Text("先跳過，等等再說 →")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkSoft)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var stepChip: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Text("1")
                    .font(AppFont.sans(13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.accent, in: Circle())
                Text("客戶資料")
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkMid)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.inkFaint)
            Text("選項目")
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkMid)
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.inkFaint)
            Text("出單")
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkMid)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.surfaceAlt, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(Color.appBorder, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        TutorialCTAScreen(onStart: { }, onSkip: { })
            .environment({
                let s = AppSettings()
                s.masterName = "陳"
                return s
            }())
    }
}
