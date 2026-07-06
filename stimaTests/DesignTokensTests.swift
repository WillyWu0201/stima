import Testing
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
@testable import stima

@Suite("DesignTokens · Color(hex:) / 狀態色 / 字體")
@MainActor
struct DesignTokensTests {

    #if canImport(UIKit)
    /// 把 SwiftUI Color 解析成 sRGB 分量。
    private func rgb(_ color: Color) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b)
    }

    @Test("Color(hex:) 正確拆出 RGB")
    func hexToRGB() {
        let c = rgb(Color(hex: 0x3366CC))   // 51,102,204 → 0.2,0.4,0.8
        #expect(abs(c.r - 0.2) < 0.01)
        #expect(abs(c.g - 0.4) < 0.01)
        #expect(abs(c.b - 0.8) < 0.01)
    }

    @Test("Color(hex:) 邊界：黑與白")
    func hexBlackAndWhite() {
        let black = rgb(Color(hex: 0x000000))
        #expect(black.r < 0.01 && black.g < 0.01 && black.b < 0.01)
        let white = rgb(Color(hex: 0xFFFFFF))
        #expect(white.r > 0.99 && white.g > 0.99 && white.b > 0.99)
    }
    #endif

    @Test("每個 QuoteStatus 對到指定語意色")
    func statusColor() {
        #expect(QuoteStatus.draft.color   == .inkFaint)
        #expect(QuoteStatus.ongoing.color == .accent)
        #expect(QuoteStatus.done.color    == .positive)
        #expect(QuoteStatus.paid.color    == .cool)
    }

    @Test("AppFont.mono 與 sans 不同（等寬 vs 一般）")
    func monoDiffersFromSans() {
        #expect(AppFont.mono(12) != AppFont.sans(12))
    }
}
