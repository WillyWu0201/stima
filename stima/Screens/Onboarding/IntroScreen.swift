import SwiftUI

/// 畫面 02 · 功能介紹
/// 3 張 feature card，介紹 app 主要能力。
struct IntroScreen: View {
    let onNext: () -> Void
    @Environment(\.dismiss) private var dismiss

    private struct Point {
        let symbol: String
        let color: Color
        let title: String
        let desc: String
    }

    private let points: [Point] = [
        .init(symbol: "doc.text",
              color: .accent,
              title: "建立報價單",
              desc: "套用以前用過的項目，不用每次重新查價。"),
        .init(symbol: "dollarsign.circle",
              color: .cool,
              title: "追收款進度",
              desc: "進行中、已完工、已收款，自動分類，一眼看清。"),
        .init(symbol: "chart.line.uptrend.xyaxis",
              color: .positive,
              title: "看自己賺多少",
              desc: "每月收入、最大客戶、最賺項目，都幫你算好。"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BackButton(action: { dismiss() })
                .padding(.bottom, 20)

            Text("它能幫你做什麼？")
                .font(AppFont.sans(30, weight: .bold))
                .foregroundStyle(Color.ink)
                .kerning(-0.6)
                .padding(.bottom, 8)

            Text("三件不用再用紙筆做的事 ↓")
                .font(AppFont.sans(14))
                .foregroundStyle(Color.inkSoft)
                .padding(.bottom, 24)

            VStack(spacing: 12) {
                ForEach(points.indices, id: \.self) { i in
                    pointCard(points[i])
                }
            }

            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bgPaper)
        .safeAreaInset(edge: .bottom) {
            BottomCTA(withBackground: false) {
                PrimaryButton("看起來不錯，繼續", systemImage: "arrow.right") {
                    onNext()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func pointCard(_ p: Point) -> some View {
        AppCard {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.surfaceAlt)
                    Image(systemName: p.symbol)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(p.color)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(p.title)
                        .font(AppFont.sans(17, weight: .bold))
                        .foregroundStyle(Color.ink)
                    Text(p.desc)
                        .font(AppFont.sans(13.5))
                        .foregroundStyle(Color.inkSoft)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        IntroScreen(onNext: { })
    }
}
