import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// Design tokens for Theme A (踏實版) — brick orange on warm cream.
// Source: design_handoff_quote_app/themes.jsx
// Dark mode variants are handled via the adaptive Color initialiser.

extension Color {
    // MARK: - Background
    static let bgPaper      = Color(light: 0xF5F2EC, dark: 0x17140F)
    static let bgSoft       = Color(light: 0xEFEAE0, dark: 0x1F1B16)
    static let appSurface   = Color(light: 0xFFFFFF, dark: 0x26221C)
    static let surfaceAlt   = Color(light: 0xFAF7F1, dark: 0x2E2923)

    // MARK: - Text
    static let ink          = Color(light: 0x1A1A1A, dark: 0xF2EDE3)
    static let inkMid       = Color(light: 0x3D3833, dark: 0xCFC7BB)
    static let inkSoft      = Color(light: 0x6B6660, dark: 0x9A9085)
    static let inkFaint     = Color(light: 0x9B8E7A, dark: 0x6E6459)

    // MARK: - Borders
    static let appBorder        = Color(light: 0xE5E0D5, dark: 0x3A332C)
    static let borderStrong = Color(light: 0xC9BFB0, dark: 0x52473A)

    // MARK: - Semantic
    /// Brick orange — primary CTA, 進行中 status, active tab fill
    static let accent       = Color(light: 0xC9522A, dark: 0xE89B5C)
    /// Peach — large money displays
    static let accent2      = Color(light: 0xE89B5C, dark: 0xC9522A)
    /// Moss green — 已完工 status
    static let positive     = Color(light: 0x5C8A6B, dark: 0x7FB890)
    /// Slate blue — 已收款 status
    static let cool         = Color(light: 0x3E6B9B, dark: 0x7FA8D6)
    static let warn         = Color(light: 0xA37B2E, dark: 0xA37B2E)

    // MARK: - Accent surface (always dark — NEVER inverts)
    /// Used for header / hero cards. Stays dark in both light and dark mode.
    static let accentSurface    = Color(light: 0x1A1A1A, dark: 0x0E0B07)
    static let accentSurfaceInk = Color(light: 0xF5F2EC, dark: 0xF2EDE3)

    // MARK: - On-accent text tints
    // Semantic shades for text / hairlines drawn over the dark accent surface,
    // so the same opacities aren't re-typed across every hero card.
    static let onAccentMuted = accentSurfaceInk.opacity(0.7)   // secondary labels
    static let onAccentFaint = accentSurfaceInk.opacity(0.55)  // tertiary captions
    static let onAccentLine  = accentSurfaceInk.opacity(0.2)   // divider hairline

    // MARK: - Hex init
    init(light: UInt, dark: UInt) {
        #if os(iOS) || os(visionOS)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hex: dark)
                : UIColor(hex: light)
        })
        #else
        // macOS: light variant; dark mode can be wired up later if needed
        self.init(hex: light)
        #endif
    }

    init(hex: UInt) {
        self.init(
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double(hex         & 0xFF) / 255
        )
    }
}

#if os(iOS) || os(visionOS)
private extension UIColor {
    convenience init(hex: UInt) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat(hex         & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif

// MARK: - Quote status

enum QuoteStatus: String, Codable, CaseIterable {
    case draft   = "draft"
    case ongoing = "ongoing"
    case done    = "done"
    case billed  = "billed"
    case paid    = "paid"

    var label: String {
        switch self {
        case .draft:   "草稿"
        case .ongoing: "進行中"
        case .done:    "已完工"
        case .billed:  "請款中"
        case .paid:    "已收款"
        }
    }

    var color: Color {
        switch self {
        case .draft:   .inkFaint
        case .ongoing: .accent
        case .done:    .positive
        case .billed:  .warn
        case .paid:    .cool
        }
    }
}

// MARK: - Typography

enum AppFont {
    // 目前用系統字體：iOS 在中文環境下會自動採用 PingFang TC。
    // 若之後要換成 Noto Sans TC / IBM Plex Mono，把字體檔加進 Xcode 後再改回 .custom。
    /// 使用者字級倍率（0.85–1.25），由 AppSettings.fontScale 驅動。
    /// app 啟動與設定變更時同步；所有 sans/mono 字級都會乘上它。
    static var scale: CGFloat = 1

    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size * scale, weight: weight)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size * scale, weight: weight, design: .monospaced)
    }

    // Named scale steps
    static let hero:      CGFloat = 28
    static let navTitle:  CGFloat = 22
    static let money:     CGFloat = 20
    static let formInput: CGFloat = 17
    static let body:      CGFloat = 15
    static let sublabel:  CGFloat = 13
    static let hint:      CGFloat = 11
}

// MARK: - Spacing

enum Spacing {
    static let screenH: CGFloat = 20   // horizontal screen padding
    static let card:    CGFloat = 16   // card internal padding
    static let cardGap: CGFloat = 12   // gap between stacked cards
    static let row:     CGFloat = 10   // gap between items in a row
}

// MARK: - Radii

enum Radius {
    static let small: CGFloat = 6     // inline mini-fields, chips inside cards
    static let card:  CGFloat = 14
    static let big:   CGFloat = 22
    static let pill:  CGFloat = 999
    static let sheet: CGFloat = 12    // page-sheet top corners
}
