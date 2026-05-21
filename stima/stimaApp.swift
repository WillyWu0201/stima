import SwiftUI
import SwiftData

@main
struct stimaApp: App {
    /// UI 測試專用 launch argument。出現任一就走測試模式：
    /// - `--uitest-reset`：清掉 UserDefaults 內 onboarding / PRO 等狀態
    /// - `--uitest-inmemory`：SwiftData 用 in-memory，每次 launch 都乾淨
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
        if let container = try? ModelContainer(for: schema, configurations: [primary]) {
            return container
        }

        // 失敗 → fallback in-memory，至少不要 crash
        // 常見原因：schema migration 失敗、磁碟空間不足、context corrupt
        print("⚠️ Disk-based ModelContainer 建立失敗，fallback in-memory（資料不會儲存）")
        let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [fallback])
        } catch {
            fatalError("連 in-memory ModelContainer 都建不起來：\(error)")
        }
    }()

    @State private var settings: AppSettings

    init() {
        if ProcessInfo.processInfo.arguments.contains("--uitest-reset") {
            for key in ["hasSeenOnboarding", "isPro", "masterName", "taxRate",
                        "currency", "language", "categories", "fontScale"] {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        _settings = State(initialValue: AppSettings())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(settings)
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
    }
}
