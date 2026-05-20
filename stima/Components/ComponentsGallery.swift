import SwiftUI

#if DEBUG
/// 開發用的元件展示頁。打開這個檔案在 Xcode 看 Preview，可一次看到所有共用元件。
/// 之後元件變動或新增時，順手更新這裡，方便視覺迴歸檢查。
struct ComponentsGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                section("AppHeader") {
                    VStack(spacing: 0) {
                        AppHeader(title: "我的報價單", subtitle: "歡迎，陳師傅", accent: true) {
                            Image(systemName: "plus")
                                .font(.system(size: 22))
                        }
                        AppHeader(title: "報價單模板", subtitle: "設定", onBack: { }) {
                            Text("預覽")
                                .font(AppFont.sans(AppFont.body, weight: .semibold))
                                .foregroundStyle(Color.accent)
                        }
                        AppHeader(title: "客戶簿")
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                }

                section("StatusBadge") {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            StatusBadge(.ongoing)
                            StatusBadge(.done)
                            StatusBadge(.paid)
                            StatusBadge(.draft)
                        }
                        HStack(spacing: 10) {
                            StatusBadge(.ongoing, large: true)
                            StatusBadge(.done,    large: true)
                            StatusBadge(.paid,    large: true)
                            StatusBadge(.draft,   large: true)
                        }
                    }
                }

                section("Money") {
                    VStack(alignment: .leading, spacing: 10) {
                        moneyRow("預設（18pt）",  Money(285_000))
                        moneyRow("大金額（28pt）", Money(285_000, size: 28, color: .accent2))
                        moneyRow("待收款（20pt）", Money(156_000, size: 20, color: .positive))
                        moneyRow("小計（16pt）",   Money(98_000,  size: 16, color: .ink, bold: false))
                    }
                }

                section("AppCard") {
                    VStack(spacing: Spacing.cardGap) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("王先生")
                                    .font(AppFont.sans(AppFont.formInput, weight: .semibold))
                                Text("台北市信義區")
                                    .font(AppFont.sans(AppFont.sublabel))
                                    .foregroundStyle(Color.inkSoft)
                            }
                        }

                        AppCard(accent: true) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("小計").font(AppFont.sans(AppFont.sublabel)).foregroundStyle(Color.accentSurfaceInk.opacity(0.7))
                                HStack {
                                    Text("總計")
                                        .font(AppFont.sans(AppFont.body, weight: .semibold))
                                        .foregroundStyle(Color.accentSurfaceInk)
                                    Spacer()
                                    Money(285_000, size: 28, color: .accent2)
                                }
                            }
                        }
                    }
                }

                section("Buttons") {
                    VStack(spacing: 12) {
                        PrimaryButton("下一步:加項目") { }
                        PrimaryButton("出單，搞定", systemImage: "checkmark") { }
                        SecondaryButton("傳給客戶", systemImage: "square.and.arrow.up") { }
                        SecondaryButton("複製這張") { }
                    }
                }

                section("AppDivider") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("項目 A").font(AppFont.sans(AppFont.body))
                        AppDivider()
                        Text("項目 B").font(AppFont.sans(AppFont.body))
                        AppDivider(color: .borderStrong)
                        Text("項目 C").font(AppFont.sans(AppFont.body))
                    }
                }
            }
            .padding(Spacing.screenH)
        }
        .background(Color.bgPaper)
        .safeAreaInset(edge: .bottom) {
            BottomCTA {
                PrimaryButton("BottomCTA 範例") { }
            } above: {
                HStack {
                    Text("目前小計")
                        .font(AppFont.sans(AppFont.sublabel))
                        .foregroundStyle(Color.inkSoft)
                    Spacer()
                    Money(52_000, size: 18, color: .accent2)
                }
            }
        }
    }

    @ViewBuilder
    private func moneyRow<M: View>(_ label: String, _ money: M) -> some View {
        HStack {
            Text(label)
                .font(AppFont.sans(AppFont.sublabel))
                .foregroundStyle(Color.inkSoft)
            Spacer()
            money
        }
    }

    @ViewBuilder
    private func section<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.mono(11, weight: .semibold))
                .foregroundStyle(Color.inkFaint)
                .textCase(.uppercase)
                .kerning(1.4)
            content()
        }
    }
}

#Preview("Light") {
    ComponentsGallery()
}

#Preview("Dark") {
    ComponentsGallery()
        .preferredColorScheme(.dark)
}
#endif
