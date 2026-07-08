import SwiftUI

/// 畫面 04 · 新增報價單 — 基本資料
/// 三個欄位：客戶稱呼 / 工程地點（含「地圖」按鈕）/ 報價日期。
struct NewQuoteInfoScreen: View {
    @Bindable var draft: NewQuoteDraft
    let onCancel: () -> Void
    let onNext: () -> Void
    @Environment(TutorialState.self) private var tutorial
    @State private var mapOpen = false
    @State private var coachDone = false

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "基本資料",
                subtitle: "新增報價單 · 1 / 3",
                onBack: { onCancel() }
            )

            ScrollView {
                VStack(spacing: 16) {
                    FieldRow(label: "客戶稱呼", systemImage: "person") {
                        AppTextField(text: $draft.clientName,
                                     placeholder: "例：王先生、林太太",
                                     maxLength: 30)
                    }
                    .coachAnchor("info")

                    FieldRow(label: "工程地點", systemImage: "mappin") {
                        HStack(spacing: 8) {
                            AppTextField(text: $draft.location,
                                         placeholder: "例：台北市信義區",
                                         maxLength: 100)
                            mapButton
                        }
                    }

                    FieldRow(label: "報價日期", systemImage: "calendar") {
                        // 用 .graphical（inline）而非 .compact：compact 展開的日曆是帶
                        // 全螢幕關閉背板的 overlay，開著時會蓋住底部「下一步」讓它點不到
                        // → 使用者填完日期後會卡住無法進下一頁。inline 不擋任何控制項。
                        DatePicker("", selection: $draft.date,
                                   displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .tint(.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.appSurface,
                                        in: RoundedRectangle(cornerRadius: Radius.card,
                                                             style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.card,
                                                 style: .continuous)
                                    .strokeBorder(Color.appBorder, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            BottomCTA {
                PrimaryButton("下一步:加項目", systemImage: "arrow.right") {
                    onNext()
                }
            }
        }
        .sheet(isPresented: $mapOpen) {
            LocationPickerSheet(address: $draft.location)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .coachMark(active: tutorial.coachingActive && !coachDone,
                   target: "info",
                   text: "先填客戶名跟工程地點，填好按下面的「下一步」。") {
            coachDone = true
        }
    }

    private var mapButton: some View {
        Button {
            mapOpen = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "mappin")
                    .font(.system(size: 14, weight: .semibold))
                Text("地圖")
                    .font(AppFont.sans(13, weight: .semibold))
            }
            .foregroundStyle(Color.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 13)
            .background(Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.card,
                                             style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card,
                                 style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        NewQuoteInfoScreen(
            draft: NewQuoteDraft(),
            onCancel: {},
            onNext: {}
        )
    }
    .environment(TutorialState())
}
