import SwiftUI
import UIKit

/// 畫面 04 · 新增報價單 — 基本資料
/// 三個欄位：客戶稱呼 / 工程地點（含「地圖」按鈕）/ 報價日期。
struct NewQuoteInfoScreen: View {
    @Bindable var draft: NewQuoteDraft
    let onCancel: () -> Void
    let onNext: () -> Void
    @Environment(TutorialState.self) private var tutorial
    @State private var mapOpen = false
    @State private var dateSheetOpen = false
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
                        // 點一下開 sheet 挑日期：先收鍵盤（避免「鍵盤+日曆並存」），
                        // 日曆在 sheet 裡有完整空間，也不會像 compact overlay 蓋住底部「下一步」。
                        Button {
                            dismissKeyboard()
                            dateSheetOpen = true
                        } label: {
                            HStack(spacing: 8) {
                                Text(Self.dateString(draft.date))
                                    .font(AppFont.sans(15))
                                    .foregroundStyle(Color.ink)
                                Spacer()
                                Image(systemName: "calendar")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.inkSoft)
                            }
                            .padding(.horizontal, 14)
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
                        .accessibilityIdentifier("dateRow")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .scrollDismissesKeyboard(.interactively)
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
        .sheet(isPresented: $dateSheetOpen) {
            NavigationStack {
                VStack {
                    DatePicker("報價日期", selection: $draft.date,
                               displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .tint(.accent)
                        .padding()
                    Spacer()
                }
                .background(Color.bgPaper)
                .navigationTitle("報價日期")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完成") { dateSheetOpen = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .coachMark(active: tutorial.coachingActive && !coachDone,
                   target: "info",
                   text: "先填客戶名跟工程地點，填好按下面的「下一步」。") {
            coachDone = true
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    private static func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
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
