import SwiftUI

#if canImport(UIKit)
import UIKit

/// 這個 app 幾乎每個 drill-in 畫面都隱藏原生 navigation bar、改用自訂 `AppHeader`。
/// 隱藏 nav bar 的副作用是：系統會一併停用「從畫面左緣滑動返回」這個原生手勢。
///
/// `SwipeBackEnabler` 把該手勢接回來——返回鍵本來就會 `dismiss()`（等同原生 pop），
/// 加上這個之後，滑動返回也回到原生體驗，而且不必犧牲深色 hero header 的設計。
///
/// 在每個 `NavigationStack` 的 root 套一次即可（已整合進 `appRoutes()`）。
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {
        DispatchQueue.main.async {
            guard let nav = vc.navigationController,
                  let pop = nav.interactivePopGestureRecognizer else { return }
            context.coordinator.nav = nav
            pop.delegate = context.coordinator
            pop.isEnabled = true
        }
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var nav: UINavigationController?

        // 只有 stack 裡還有上一頁時才允許滑動返回，避免在 root 觸發。
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (nav?.viewControllers.count ?? 0) > 1
        }
    }
}

extension View {
    /// 恢復隱藏 nav bar 畫面的原生左緣滑動返回手勢。
    func enableSwipeBack() -> some View {
        background(
            SwipeBackEnabler()
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
        )
    }
}

#else

extension View {
    /// 非 UIKit 平台（macOS）沒有滑動返回手勢，no-op。
    func enableSwipeBack() -> some View { self }
}

#endif
