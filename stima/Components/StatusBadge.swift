import SwiftUI

/// 狀態 pill。10% opacity 底色 + 粗體文字 + 小圓點。
///
/// 用法：
///   StatusBadge(.ongoing)
///   StatusBadge(.paid, large: true)
struct StatusBadge: View {
    let status: QuoteStatus
    var large: Bool = false

    init(_ status: QuoteStatus, large: Bool = false) {
        self.status = status
        self.large = large
    }

    var body: some View {
        let color = status.color
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(status.label)
                .font(AppFont.sans(large ? 12 : 11, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, large ? 11 : 8)
        .padding(.vertical, large ? 5 : 3)
        .background(color.opacity(0.10), in: Capsule())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            StatusBadge(.ongoing)
            StatusBadge(.done)
            StatusBadge(.paid)
            StatusBadge(.draft)
        }
        HStack {
            StatusBadge(.ongoing, large: true)
            StatusBadge(.done, large: true)
            StatusBadge(.paid, large: true)
            StatusBadge(.draft, large: true)
        }
    }
    .padding()
    .background(Color.bgPaper)
}
