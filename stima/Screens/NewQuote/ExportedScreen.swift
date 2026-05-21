import SwiftUI

/// 畫面 07 · 出單完成
/// 確認頁 + 下一步 prompt。第一次出單時標題不同。
struct ExportedScreen: View {
    let isFirstTime: Bool
    let onHome: () -> Void
    let onShare: () -> Void
    var shareMessage: String? = nil      // 若提供，「傳給客戶」用 ShareLink 自動觸發系統面板

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 18) {
                ZStack {
                    Circle().fill(Color.accent)
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 72, height: 72)

                VStack(spacing: 8) {
                    Text(isFirstTime ? "第一張完成！" : "出單完成")
                        .font(AppFont.sans(26, weight: .heavy))
                        .foregroundStyle(Color.ink)
                        .kerning(-0.4)

                    Text("下次跟同個客戶報價時，我們會自動幫你填好資料。")
                        .font(AppFont.sans(13))
                        .foregroundStyle(Color.inkSoft)
                        .lineSpacing(3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                }
            }
            .padding(.horizontal, 22)

            Spacer()
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()    // 沒返回路徑，已 finalized
        .safeAreaInset(edge: .bottom) {
            BottomCTA {
                VStack(spacing: 10) {
                    if let shareMessage {
                        ShareSecondaryButton(title: "傳給客戶", message: shareMessage)
                    } else {
                        SecondaryButton("傳給客戶", systemImage: "square.and.arrow.up") {
                            onShare()
                        }
                    }
                    PrimaryButton("太好了，看看主畫面") {
                        onHome()
                    }
                }
            }
        }
    }
}

#Preview("第一次") {
    NavigationStack {
        ExportedScreen(isFirstTime: true, onHome: {}, onShare: {})
    }
}

#Preview("一般") {
    NavigationStack {
        ExportedScreen(isFirstTime: false, onHome: {}, onShare: {})
    }
}
