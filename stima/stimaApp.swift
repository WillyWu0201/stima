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
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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
        if settings.hasSeenOnboarding {
            ContentView()
        } else {
            OnboardingFlow()
        }
    }
}
