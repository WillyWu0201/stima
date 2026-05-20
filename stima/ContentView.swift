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

// MARK: - Placeholder screens (replace with real implementations)

struct HomeScreen: View {
    var body: some View {
        Text("報價單列表")
            .navigationTitle("我的報價單")
    }
}

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
