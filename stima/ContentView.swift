import SwiftUI

// Root tab container. Three top-level tabs per design spec.
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("報價單", systemImage: "doc.text") {
                NavigationStack {
                    HomeScreen()
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

// MARK: - Placeholder screens (待實作)

struct StatsScreen: View {
    var body: some View {
        Text("營運統計")
            .navigationTitle("營運統計")
    }
}

struct SettingsScreen: View {
    var body: some View {
        Text("設定")
            .navigationTitle("設定")
    }
}

#Preview {
    ContentView()
}
