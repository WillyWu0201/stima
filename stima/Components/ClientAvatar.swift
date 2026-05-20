import SwiftUI

/// 客戶 avatar：圓形 + accent 底色 + 客戶名第一個字。
/// 用在報價單詳情的客戶卡、客戶簿、客戶詳情等。
///
/// 用法：
///   ClientAvatar(name: "王先生")
///   ClientAvatar(name: "陳老闆", size: 72)
struct ClientAvatar: View {
    let name: String
    var size: CGFloat = 40

    private var firstChar: String {
        String(name.prefix(1))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accent.opacity(0.12))
            Text(firstChar)
                .font(AppFont.sans(size * 0.45, weight: .bold))
                .foregroundStyle(Color.accent)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 12) {
        ClientAvatar(name: "王先生")
        ClientAvatar(name: "林太太")
        ClientAvatar(name: "陳老闆", size: 56)
        ClientAvatar(name: "黃", size: 72)
    }
    .padding()
    .background(Color.bgPaper)
}
