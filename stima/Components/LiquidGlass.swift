import SwiftUI

// iOS 26 Liquid Glass 的集中入口。
// 全部用 #available 包起來，舊系統（含專案支援的 macOS / visionOS 舊版）走 fallback。
// 形狀統一用 continuous 圓角，跟 Radius token 對齊。

extension View {

    /// 有色玻璃填底 —— 主要 CTA 用（維持品牌色但加上玻璃材質與光澤）。
    /// 舊系統 fallback 成實心色。
    @ViewBuilder
    func glassTintedFill(_ color: Color, cornerRadius: CGFloat = Radius.card) -> some View {
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            glassEffect(.regular.tint(color).interactive(),
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            background(color, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    /// 中性玻璃 —— 次要 CTA 用。舊系統 fallback 成 surface 底 + 邊框。
    @ViewBuilder
    func glassNeutral(cornerRadius: CGFloat = Radius.card) -> some View {
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            glassEffect(.regular.interactive(),
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            background(Color.appSurface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(Color.borderStrong, lineWidth: 1.5)
                )
        }
    }

    /// 底部 CTA 條的底：iOS 26 讓玻璃按鈕直接浮在內容上（不畫實心條與 hairline）；
    /// 舊系統維持 paper 底 + 上緣 hairline。
    @ViewBuilder
    func ctaBarBackground(active: Bool) -> some View {
        if #available(iOS 26, macOS 26, visionOS 26, *) {
            self
        } else {
            background(active ? Color.bgPaper : Color.clear)
                .overlay(alignment: .top) {
                    if active {
                        Rectangle().fill(Color.appBorder).frame(height: 1)
                    }
                }
        }
    }
}

/// 把多個相鄰的玻璃元件包進 `GlassEffectContainer`，讓它們在 iOS 26 正確融合 / morph。
/// 舊系統直接攤平內容。
@ViewBuilder
func GlassGroup<Content: View>(spacing: CGFloat = 8,
                               @ViewBuilder content: () -> Content) -> some View {
    if #available(iOS 26, macOS 26, visionOS 26, *) {
        GlassEffectContainer(spacing: spacing) { content() }
    } else {
        content()
    }
}
