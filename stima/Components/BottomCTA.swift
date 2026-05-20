import SwiftUI

/// 固定底部 CTA 區域。padding 已預留 home indicator 的空間（36pt）。
/// 建議用 `.safeAreaInset(edge: .bottom)` 掛到 ScrollView 底部。
///
/// 用法：
///   ScrollView { ... }
///     .safeAreaInset(edge: .bottom) {
///         BottomCTA {
///             PrimaryButton("下一步") { ... }
///         }
///     }
///
///   // 含上方的小計列
///   BottomCTA {
///       PrimaryButton("下一步:算總價") { ... }
///   } above: {
///       HStack {
///           Text("目前小計")
///               .foregroundStyle(Color.inkSoft)
///           Spacer()
///           Money(52000)
///       }
///   }
struct BottomCTA<Content: View, Above: View>: View {
    var withBackground: Bool = true
    @ViewBuilder let content: () -> Content
    @ViewBuilder let above: () -> Above

    var body: some View {
        VStack(spacing: 10) {
            above()
            content()
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 36)
        .background(withBackground ? Color.bgPaper : Color.clear)
        .overlay(alignment: .top) {
            if withBackground {
                Rectangle()
                    .fill(Color.appBorder)
                    .frame(height: 1)
            }
        }
    }
}

extension BottomCTA where Above == EmptyView {
    init(withBackground: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.withBackground = withBackground
        self.content = content
        self.above = { EmptyView() }
    }
}

#Preview {
    VStack {
        Spacer()
        BottomCTA {
            PrimaryButton("下一步:算總價") { }
        } above: {
            HStack {
                Text("目前小計")
                    .font(AppFont.sans(AppFont.sublabel))
                    .foregroundStyle(Color.inkSoft)
                Spacer()
                Money(52_000, size: 18, color: .accent2)
            }
        }
    }
    .background(Color.bgPaper)
}
