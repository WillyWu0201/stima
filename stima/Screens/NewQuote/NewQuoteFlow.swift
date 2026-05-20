import SwiftUI
import SwiftData

/// 新增報價單流程容器：04 基本資料 → 05 加項目 → 06 確認 → 07 出單完成。
/// 從 HomeScreen 以 fullScreenCover 形式呈現，linear push 流程。
struct NewQuoteFlow: View {
    let onClose: () -> Void
    let onFinished: () -> Void

    @State private var draft = NewQuoteDraft()
    @State private var path: [Step] = []

    enum Step: Hashable {
        case items
        case review
        case exported
    }

    var body: some View {
        NavigationStack(path: $path) {
            NewQuoteInfoScreen(
                draft: draft,
                onCancel: { onClose() },
                onNext:   { path.append(.items) }
            )
            .navigationDestination(for: Step.self) { step in
                switch step {
                case .items:
                    NewQuoteItemsScreen(
                        draft: draft,
                        onNext: { path.append(.review) }
                    )
                case .review:
                    Text("畫面 06 — TODO")  // 待 Task #4
                case .exported:
                    Text("畫面 07 — TODO")  // 待 Task #5
                }
            }
        }
    }
}

#Preview {
    NewQuoteFlow(onClose: {}, onFinished: {})
        .modelContainer(PreviewData.container)
}
