import SwiftUI
import SwiftData

/// 新增報價單流程容器：04 基本資料 → 05 加項目 → 06 確認 → 07 出單完成。
/// 從 HomeScreen 以 fullScreenCover 形式呈現，linear push 流程。
struct NewQuoteFlow: View {
    let onClose: () -> Void
    let onFinished: () -> Void

    @State private var draft = NewQuoteDraft()
    @State private var path: [Step] = []
    @Environment(\.modelContext) private var modelContext

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
                    NewQuoteReviewScreen(
                        draft: draft,
                        onFinish: { finalize() }
                    )
                case .exported:
                    Text("畫面 07 — TODO")  // 待 Task #5
                }
            }
        }
    }

    /// 把 draft 寫成 Quote 進 SwiftData，然後推進 .exported。
    private func finalize() {
        let quote = Quote(
            clientName: draft.clientName.isEmpty ? "未命名客戶" : draft.clientName,
            location:   draft.location,
            date:       draft.date,
            folder:     draft.folder,
            status:     .ongoing
        )
        for item in draft.items {
            quote.items.append(
                QuoteItem(name: item.name, unit: item.unit, qty: item.qty, price: item.price)
            )
        }
        quote.recalcTotal()
        modelContext.insert(quote)
        path.append(.exported)
    }
}

#Preview {
    NewQuoteFlow(onClose: {}, onFinished: {})
        .environment(AppSettings())
        .modelContainer(PreviewData.container)
}
