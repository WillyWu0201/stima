import SwiftUI

/// 畫面 12b · 新增客戶（page-sheet）
/// 由 ContactsScreen 右上 + 按鈕召喚。儲存後呼叫 onSave callback，由父層 insert 進 SwiftData。
/// 完整 form 在下個 commit。
struct NewClientSheet: View {
    let onSave: (Client) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // TODO: 完整 form
        VStack {
            Text("新增客戶 — TODO")
                .font(AppFont.sans(18, weight: .bold))
                .foregroundStyle(Color.ink)
            Spacer()
        }
        .padding()
        .background(Color.appSurface)
    }
}
