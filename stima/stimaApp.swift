import SwiftUI
import SwiftData

@main
struct stimaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quote.self,
            QuoteItem.self,
            Client.self,
            CustomItem.self,
            PDFTemplate.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var settings = AppSettings()

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
