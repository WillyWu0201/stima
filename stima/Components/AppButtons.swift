import SwiftUI

/// 主要 CTA：橙色填底 + 白字。預設 full-width。
///
/// 用法：
///   PrimaryButton("下一步") { ... }
///   PrimaryButton("出單，搞定", systemImage: "checkmark") { ... }
struct PrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(LocalizedStringKey(title))
                    .font(AppFont.sans(16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .glassTintedFill(isEnabled ? Color.accent : Color.inkFaint)
            // 整條都可點：maxWidth:.infinity + glass 讓兩側只有動畫、命中區卻只到中央文字
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// 次要 CTA：透明底 + 邊框。
struct SecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    init(_ title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(LocalizedStringKey(title))
                    .font(AppFont.sans(15, weight: .semibold))
            }
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .glassNeutral()
            // 整條都可點（同 PrimaryButton）
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton("下一步:加項目") { }
        PrimaryButton("出單，搞定", systemImage: "checkmark") { }
        SecondaryButton("傳給客戶", systemImage: "square.and.arrow.up") { }
        SecondaryButton("複製這張") { }
    }
    .padding()
    .background(Color.bgPaper)
}
