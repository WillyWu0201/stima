import SwiftUI

/// 教學引導的全域狀態（注入在 app root，跟 AppSettings 一起）。
@Observable
@MainActor
final class TutorialState {
    /// onboarding「來試一張看看」要求啟動教學；Home 看到後會自動開新報價流程。
    var requestQuoteTutorial = false
    /// 正在帶 coach mark 走新報價流程。
    var coachingActive = false

    func endCoaching() {
        coachingActive = false
        requestQuoteTutorial = false
    }
}

// MARK: - Anchor capture

private struct CoachAnchorKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>],
                       nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// 標記此 view 為 coach mark 的高亮目標。
    func coachAnchor(_ id: String) -> some View {
        anchorPreference(key: CoachAnchorKey.self, value: .bounds) { [id: $0] }
    }

    /// 在畫面 root 套用。`active` 時對 `target` id 的元件畫 spotlight + 說明氣泡。
    /// 點「知道了」呼叫 `onNext`（通常把該畫面的 coach 收掉）。
    func coachMark(active: Bool,
                   target id: String,
                   text: LocalizedStringKey,
                   onNext: @escaping () -> Void) -> some View {
        overlayPreferenceValue(CoachAnchorKey.self) { anchors in
            GeometryReader { proxy in
                if active, let anchor = anchors[id] {
                    CoachMarkOverlay(rect: proxy[anchor],
                                     bounds: proxy.size,
                                     text: text,
                                     onNext: onNext)
                }
            }
            // 整個覆蓋層用同一個全螢幕座標系，挖洞與高亮框才會對齊。
            .ignoresSafeArea()
        }
    }
}

// MARK: - Overlay

private struct CoachMarkOverlay: View {
    let rect: CGRect
    let bounds: CGSize
    let text: LocalizedStringKey
    let onNext: () -> Void

    private var targetInTopHalf: Bool { rect.midY < bounds.height / 2 }
    private let pad: CGFloat = 8

    var body: some View {
        ZStack(alignment: targetInTopHalf ? .bottom : .top) {
            Color.black.opacity(0.6)
                .reverseMask {
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .frame(width: rect.width + pad * 2, height: rect.height + pad * 2)
                        .position(x: rect.midX, y: rect.midY)
                }
                .onTapGesture { onNext() }

            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.accent2, lineWidth: 2)
                .frame(width: rect.width + pad * 2, height: rect.height + pad * 2)
                .position(x: rect.midX, y: rect.midY)
                .allowsHitTesting(false)

            bubble
                .padding(.horizontal, 22)
                .padding(.bottom, targetInTopHalf ? 48 : 0)
                .padding(.top, targetInTopHalf ? 0 : 76)
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 13, weight: .bold))
                Text("小提示")
                    .font(AppFont.sans(12, weight: .bold))
                    .kerning(0.5)
            }
            .foregroundStyle(Color.accent2)

            Text(text)
                .font(AppFont.sans(15, weight: .medium))
                .foregroundStyle(Color.accentSurfaceInk)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onNext) {
                Text("知道了")
                    .font(AppFont.sans(14, weight: .semibold))
                    .foregroundStyle(Color.accentSurface)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accent2, in: Capsule())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentSurface,
                    in: RoundedRectangle(cornerRadius: Radius.big, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
    }
}

private extension View {
    /// 反向遮罩：把 `mask` 形狀從自身挖掉（spotlight 用）。
    func reverseMask<M: View>(@ViewBuilder _ mask: () -> M) -> some View {
        self.mask {
            ZStack {
                Rectangle()
                mask().blendMode(.destinationOut)
            }
            .compositingGroup()
        }
    }
}
