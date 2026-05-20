import SwiftUI

/// 客戶 avatar：圓形 + 客戶名第一個字。
/// 兩種風格：accent（強調，如報價單詳情的客戶卡）、neutral（列表用，如客戶簿）。
///
/// 用法：
///   ClientAvatar(name: "王先生")
///   ClientAvatar(name: "王先生", style: .neutral)
///   ClientAvatar(name: "陳老闆", size: 72)
struct ClientAvatar: View {
    let name: String
    var size: CGFloat = 40
    var style: Style = .accent

    enum Style {
        case accent     // 橙色 12% 底 + 橙字
        case neutral    // 淺灰底 + 深灰字（列表用）
    }

    private var firstChar: String {
        String(name.prefix(1))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(background)
                .overlay(Circle().strokeBorder(border, lineWidth: borderWidth))
            Text(firstChar)
                .font(AppFont.sans(size * 0.45, weight: .bold))
                .foregroundStyle(foreground)
        }
        .frame(width: size, height: size)
    }

    private var background: Color {
        switch style {
        case .accent:  return Color.accent.opacity(0.12)
        case .neutral: return Color.surfaceAlt
        }
    }
    private var foreground: Color {
        switch style {
        case .accent:  return Color.accent
        case .neutral: return Color.inkMid
        }
    }
    private var border: Color {
        switch style {
        case .accent:  return .clear
        case .neutral: return Color.appBorder
        }
    }
    private var borderWidth: CGFloat {
        switch style {
        case .accent:  return 0
        case .neutral: return 1
        }
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
