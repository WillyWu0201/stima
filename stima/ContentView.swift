import SwiftUI

// Root tab container. Three top-level tabs per design spec.
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("報價單", systemImage: "doc.text") {
                NavigationStack {
                    HomeScreen()
                        .navigationDestination(for: Quote.self) { quote in
                            DetailScreen(quote: quote)
                        }
                }
            }
            Tab("統計", systemImage: "chart.bar") {
                NavigationStack {
                    StatsScreen()
                }
            }
            Tab("設定", systemImage: "gearshape") {
                NavigationStack {
                    SettingsScreen()
                }
            }
        }
        .tint(.accent)
    }
}


#Preview {
    ContentView()
}
