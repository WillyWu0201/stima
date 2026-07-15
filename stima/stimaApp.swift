import SwiftUI
import SwiftData

@main
struct stimaApp: App {
    /// UI 測試專用 launch argument。出現任一就走測試模式：
    /// - `--uitest-reset`：清掉 UserDefaults 內 onboarding / PRO 等狀態
    /// - `--uitest-inmemory`：SwiftData 用 in-memory，每次 launch 都乾淨
    /// - `--uitest-seed`：把 PreviewData 範例 client / quote 灌進 DB（給需要資料的畫面測試）
    /// - `--uitest-onboarded`：標記已看過 onboarding，直接進主畫面（跳過教學 coach mark）
    /// - `--uitest-pro`：標記為 PRO 用戶（測進階功能，如統計淨利卡）
    private static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains { $0.hasPrefix("--uitest-") }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
            QuoteItem.self,
            Client.self,
            CustomItem.self,
            PDFTemplate.self,
        ])
        let inMemory = ProcessInfo.processInfo.arguments.contains("--uitest-inmemory")
        let primary = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        // 先試 disk-based（或 UI 測試指定的 in-memory）
        do {
            return try ModelContainer(for: schema, configurations: [primary])
        } catch {
            // 失敗 → fallback in-memory，至少不要 crash。務必印出真正原因：
            // 最常見是「新加的 @Model 欄位沒有屬性層級預設值」導致輕量遷移失敗，
            // 靜默 fallback 會讓資料每次啟動都不見，很難察覺。
            print("⚠️ Disk-based ModelContainer 建立失敗，fallback in-memory（資料不會儲存）：\(error)")
        }
        let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [fallback])
        } catch {
            fatalError("連 in-memory ModelContainer 都建不起來：\(error)")
        }
    }()

    @State private var settings: AppSettings
    @State private var tutorial = TutorialState()

    init() {
        if ProcessInfo.processInfo.arguments.contains("--uitest-reset") {
            for key in ["hasSeenOnboarding", "isPro", "masterName", "taxRate",
                        "currency", "language", "categories", "fontScale"] {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        if ProcessInfo.processInfo.arguments.contains("--uitest-onboarded") {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
        if ProcessInfo.processInfo.arguments.contains("--uitest-pro") {
            UserDefaults.standard.set(true, forKey: "isPro")
        }
        _settings = State(initialValue: AppSettings())
        PurchaseManager.shared.configure()

        if ProcessInfo.processInfo.arguments.contains("--uitest-seed") {
            Self.seedSampleData(into: sharedModelContainer)
        }
    }

    /// UI 測試用：把 PreviewData 的範例 client / quote 灌進 DB，
    /// 讓 Detail / ClientDetail / ItemDetail / Stats 等需要資料的畫面能被 UI 測試走到。
    @MainActor
    private static func seedSampleData(into container: ModelContainer) {
        let ctx = container.mainContext
        PreviewData.makeSampleClients().forEach { ctx.insert($0) }
        PreviewData.makeSampleQuotes().forEach { q in
            q.recalcTotal()   // 用一致的 5% 稅金總計，避免詳情/PDF 反推出怪異稅率
            ctx.insert(q)
        }
        let template = PDFTemplate()
        template.businessName = "大發工程行"
        template.phone = "02-2345-6789"
        template.paymentInfo = "匯款：玉山銀行(808) 1234-567-890\nLINE Pay：掃描下方 QR Code\n現金：請電 0912-345-678"
        ctx.insert(template)
        try? ctx.save()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
                .environment(tutorial)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Root — onboarding gate

struct RootView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Group {
            if settings.hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingFlow()
            }
        }
        .environment(\.locale, Locale(identifier: settings.language))
        .environment(\.currencySymbol, settings.currencySymbol)
        .dismissKeyboardOnTapOutside()
        .task {
            await PurchaseManager.shared.syncEntitlement(into: settings)
        }
    }
}
