import SwiftUI

/// 區塊小標籤（mono、uppercase、letter-spacing）。用於 Settings 與 Detail 等畫面的 section 標頭。
///
/// 用法：
///   SectionTitle("同步與備份")
struct SectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(LocalizedStringKey(title))
            .font(AppFont.sans(13, weight: .semibold))
            .foregroundStyle(Color.inkSoft)
            .padding(.top, 4)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 4) {
        SectionTitle("同步與備份")
        SectionTitle("個人")
        SectionTitle("商務")
    }
    .padding()
    .background(Color.bgPaper)
}
