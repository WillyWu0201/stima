import SwiftUI

/// 客戶詳情頁的 navigation value（用 wrapper 而非裸 String 避免跟其他 String 路由衝突）。
struct ClientRoute: Hashable {
    let name: String
}

/// 項目詳情頁的 navigation value。
struct ItemRoute: Hashable {
    let name: String
}

/// 套用 app 標準 drill-in 路由：報價單詳情、客戶詳情、項目詳情。
/// 每個 NavigationStack root 用一次即可，stack 內任何 view 都能 push。
struct AppRoutesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Quote.self) { quote in
                DetailScreen(quote: quote)
            }
            .navigationDestination(for: ClientRoute.self) { route in
                ClientDetailScreen(clientName: route.name)
            }
            .navigationDestination(for: ItemRoute.self) { route in
                ItemDetailScreen(itemName: route.name)
            }
    }
}

extension View {
    /// 套用 app 內全域 drill-in 路由（Quote 詳情 / Client 詳情）。
    func appRoutes() -> some View {
        modifier(AppRoutesModifier())
    }
}
