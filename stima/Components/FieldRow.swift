import SwiftUI

/// 表單列：上方 icon + label，下方 input 或任意 content。
/// 畫面 04 / 12b / 13 等表單都用這個結構。
///
/// 用法：
///   FieldRow(label: "客戶稱呼", systemImage: "person") {
///       AppTextField(text: $client, placeholder: "例：王先生、林太太")
///   }
struct FieldRow<Content: View>: View {
    let label: String
    var systemImage: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .regular))
                }
                Text(LocalizedStringKey(label))
                    .font(AppFont.sans(13, weight: .semibold))
            }
            .foregroundStyle(Color.inkSoft)

            content()
        }
    }
}

#Preview {
    @Previewable @State var client = "王先生"
    @Previewable @State var date = "2026-05-20"
    VStack(spacing: 16) {
        FieldRow(label: "客戶稱呼", systemImage: "person") {
            AppTextField(text: $client, placeholder: "例：王先生、林太太")
        }
        FieldRow(label: "報價日期", systemImage: "calendar") {
            AppTextField(text: $date, placeholder: "2026-05-20")
        }
    }
    .padding()
    .background(Color.bgPaper)
}
