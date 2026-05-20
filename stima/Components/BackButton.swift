import SwiftUI

/// 自訂的返回按鈕（不用 NavigationStack 內建 toolbar）。
/// 設計稿許多畫面隱藏 nav bar、把 back arrow 放在內容區頂部，這個元件就是給那種版型用。
///
/// 用法：
///   BackButton { dismiss() }
struct BackButton: View {
    let action: () -> Void
    var color: Color = .inkSoft

    init(color: Color = .inkSoft, action: @escaping () -> Void) {
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("返回")
    }
}

#Preview {
    HStack(spacing: 20) {
        BackButton { }
        BackButton(color: .accent) { }
        BackButton(color: .accentSurfaceInk) { }
            .padding()
            .background(Color.accentSurface)
    }
    .padding()
    .background(Color.bgPaper)
}
