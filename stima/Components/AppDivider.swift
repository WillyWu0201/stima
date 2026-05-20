import SwiftUI

/// 虛線分隔（SwiftUI 內建的 Divider 是實線，設計稿用虛線）。
///
/// 用法：
///   AppDivider()
struct AppDivider: View {
    var color: Color = .appBorder

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 1)
            .overlay(
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(color)
            )
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}

#Preview {
    VStack(spacing: 16) {
        Text("項目 A")
        AppDivider()
        Text("項目 B")
        AppDivider(color: .borderStrong)
        Text("項目 C")
    }
    .padding()
    .background(Color.bgPaper)
}
