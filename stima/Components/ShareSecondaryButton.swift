import SwiftUI

/// SecondaryButton 視覺風格的 ShareLink — 點下去觸發系統分享面板。
///
/// 用法：
///   ShareSecondaryButton(title: "傳給客戶",
///                        message: ShareMessage.forQuote(quote, masterName: name))
struct ShareSecondaryButton: View {
    let title: String
    var systemImage: String = "square.and.arrow.up"
    let message: String

    var body: some View {
        ShareLink(item: message) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                Text(LocalizedStringKey(title))
                    .font(AppFont.sans(15, weight: .semibold))
            }
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .glassNeutral()
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ShareSecondaryButton(title: "傳給客戶",
                             message: "範例訊息")
        ShareSecondaryButton(title: "分享",
                             message: "另一個範例")
    }
    .padding()
    .background(Color.bgPaper)
}
