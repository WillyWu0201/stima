import SwiftUI
import UIKit

/// 全 App 級「點空白處收鍵盤」。
///
/// SwiftUI 預設點輸入框外面不會收鍵盤，使用者常覺得鍵盤收不下去。這裡在 UIWindow 掛一個
/// tap gesture：點任何地方都會 resignFirstResponder（收鍵盤）。關鍵是
/// `cancelsTouchesInView = false` + 允許同時辨識，所以**不會吃掉**底下按鈕／欄位／捲動的觸控。
final class WindowTapToDismissKeyboard: NSObject, UIGestureRecognizerDelegate {
    static let shared = WindowTapToDismissKeyboard()

    private static let gestureName = "kbDismissTap"

    /// 在 window 上裝手勢（重複呼叫安全，不會重複掛）。
    func install() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                let already = window.gestureRecognizers?.contains { $0.name == Self.gestureName } ?? false
                if already { continue }
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                tap.name = Self.gestureName
                tap.cancelsTouchesInView = false   // 不擋底下的點擊
                tap.delegate = self
                window.addGestureRecognizer(tap)
            }
        }
    }

    @objc private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    // 與其他手勢（捲動、按鈕等）並存，不互斥
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        true
    }
}

extension View {
    /// 掛在 app root：畫面出現後於 window 裝上「點空白收鍵盤」手勢。
    func dismissKeyboardOnTapOutside() -> some View {
        onAppear {
            // 等 window attach 完再裝
            DispatchQueue.main.async { WindowTapToDismissKeyboard.shared.install() }
        }
    }
}
