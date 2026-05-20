import SwiftUI

/// 標準 styling 的文字輸入框（白底 + 邊框 + 圓角）。
///
/// 用法：
///   AppTextField(text: $name, placeholder: "例：王先生")
///   AppTextField(text: $price, placeholder: "0")
///       .keyboardType(.decimalPad)
struct AppTextField: View {
    @Binding var text: String
    var placeholder: String

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
