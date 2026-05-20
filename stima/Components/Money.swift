import SwiftUI

/// 金額顯示元件：千分位 + tabular-nums + 可調尺寸/顏色。
///
/// 用法：
///   Money(285000)
///   Money(285000, size: 28, color: .accent2, bold: true)
struct Money: View {
    let amount: Int
    var size: CGFloat = 18
    var color: Color = .accent
    var prefix: String = "$"
    var bold: Bool = true

    var body: some View {
        Text("\(prefix)\(amount.formatted(.number.grouping(.automatic)))")
            .font(AppFont.sans(size, weight: bold ? .bold : .medium))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        Money(285_000)
        Money(285_000, size: 28, color: .accent2)
        Money(156_000, size: 20, color: .positive)
        Money(98_000,  size: 16, color: .ink, bold: false)
    }
    .padding()
    .background(Color.bgPaper)
}
