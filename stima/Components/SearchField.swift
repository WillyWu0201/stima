import SwiftUI

/// 搜尋輸入框：放大鏡 icon + placeholder + 清除按鈕。
///
/// 用法：
///   SearchField(text: $search, placeholder: "搜尋客戶、地點、項目（例：冷氣）")
struct SearchField: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.inkSoft)

            TextField(placeholder, text: $text)
                .font(AppFont.sans(16))
                .foregroundStyle(Color.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.inkFaint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清除搜尋")
            }
        }
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
    @Previewable @State var t1 = ""
    @Previewable @State var t2 = "冷氣"
    VStack(spacing: 12) {
        SearchField(text: $t1, placeholder: "搜尋客戶、地點、項目（例：冷氣）")
        SearchField(text: $t2, placeholder: "搜尋")
    }
    .padding()
    .background(Color.bgPaper)
}
