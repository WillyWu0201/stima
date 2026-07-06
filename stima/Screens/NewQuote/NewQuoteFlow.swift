import SwiftUI
import SwiftData

/// 新增報價單流程容器：04 基本資料 → 05 加項目 → 06 確認 → 07 出單完成。
/// 從 HomeScreen 以 fullScreenCover 形式呈現，linear push 流程。
struct NewQuoteFlow: View {
    let onClose: () -> Void
    let onFinished: () -> Void

    @State private var draft: NewQuoteDraft
    @State private var path: [Step]
    @State private var wasFirstQuote = false
    @State private var finalizedQuote: Quote? = nil
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Environment(TutorialState.self) private var tutorial
    @Query private var allQuotes: [Quote]

    enum Step: Hashable {
        case items
        case review
        case exported
    }

    /// `initialDraft` 帶入 existing 內容（例：從 Detail「複製這張」）。
    /// `startAt` 指定要直接跳到哪一步，會把前面的 step 也 push 進 stack 以保留返回路徑。
    init(initialDraft: NewQuoteDraft? = nil,
         startAt: Step? = nil,
         onClose: @escaping () -> Void,
         onFinished: @escaping () -> Void) {
        self.onClose = onClose
        self.onFinished = onFinished
        _draft = State(initialValue: initialDraft ?? NewQuoteDraft())

        var initialPath: [Step] = []
        if let startAt {
            let order: [Step] = [.items, .review, .exported]
            if let idx = order.firstIndex(of: startAt) {
                initialPath = Array(order[0...idx])
            }
        }
        _path = State(initialValue: initialPath)
    }

    var body: some View {
        NavigationStack(path: $path) {
            NewQuoteInfoScreen(
                draft: draft,
                onCancel: {
                    tutorial.endCoaching()
                    onClose()
                },
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
                    ExportedScreen(
                        isFirstTime: wasFirstQuote,
                        onHome:  { onFinished() },
                        onShare: {},
                        shareMessage: finalizedQuote.map {
                            ShareMessage.forQuote($0, masterName: settings.masterName, currencySymbol: settings.currencySymbol)
                        }
                    )
                }
            }
        }
    }

    /// 把 draft 寫成 Quote 進 SwiftData，然後推進 .exported。
    private func finalize() {
        // 在 insert 之前記錄是否為第一筆，以便 ExportedScreen 顯示不同文案。
        wasFirstQuote = allQuotes.isEmpty

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
        quote.recalcTotal(taxRatePercent: settings.taxRate)
        modelContext.insert(quote)
        finalizedQuote = quote
        tutorial.endCoaching()
        path.append(.exported)
    }
}

#Preview {
    NewQuoteFlow(onClose: {}, onFinished: {})
        .environment(AppSettings())
        .environment(TutorialState())
        .modelContainer(PreviewData.container)
}
