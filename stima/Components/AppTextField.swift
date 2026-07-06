import SwiftUI

/// 標準 styling 的文字輸入框（白底 + 邊框 + 圓角）。
/// `maxLength` 可選 — 超過會即時截斷。
///
/// 用法：
///   AppTextField(text: $name, placeholder: "例：王先生")
///   AppTextField(text: $price, placeholder: "0", maxLength: 10)
///       .keyboardType(.decimalPad)
struct AppTextField: View {
    @Binding var text: String
    var placeholder: LocalizedStringKey
    var maxLength: Int? = nil

    var body: some View {
        TextField(placeholder, text: $text)
            .font(AppFont.sans(16))
            .foregroundStyle(Color.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.appSurface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1.5)
            )
            .onChange(of: text) { _, new in
                if let max = maxLength, new.count > max {
                    text = String(new.prefix(max))
                }
            }
    }
}

#Preview {
    @Previewable @State var a = ""
    @Previewable @State var b = "王先生"
    VStack(spacing: 12) {
        AppTextField(text: $a, placeholder: "例：王先生、林太太")
        AppTextField(text: $b, placeholder: "客戶名")
    }
    .padding()
    .background(Color.bgPaper)
}
