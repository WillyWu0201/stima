import SwiftUI

/// 畫面 12b · 新增客戶（page-sheet）
/// 從 ContactsScreen 右上 + 按鈕召喚。儲存後呼叫 onSave，由父層 insert 進 SwiftData。
struct NewClientSheet: View {
    var existingNames: Set<String> = []
    let onSave: (Client) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var notes = ""
    @State private var mapOpen = false
    @State private var showingDuplicateAlert = false

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView {
                VStack(spacing: 14) {
                    avatarPreview
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    FieldRow(label: "客戶稱呼 ＊", systemImage: "person") {
                        AppTextField(text: $name, placeholder: "例：王先生、林太太、陳老闆")
                    }
                    FieldRow(label: "電話", systemImage: "phone") {
                        AppTextField(text: $phone, placeholder: "0912-345-678")
                            .keyboardType(.phonePad)
                    }
                    FieldRow(label: "Email（可省略）", systemImage: "envelope") {
                        AppTextField(text: $email, placeholder: "example@email.com")
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    FieldRow(label: "工程地址", systemImage: "mappin") {
                        HStack(spacing: 8) {
                            AppTextField(text: $address, placeholder: "例：台北市信義區松仁路")
                            mapButton
                        }
                    }
                    FieldRow(label: "備註（可省略）", systemImage: "doc.text") {
                        notesEditor
                    }

                    hintCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .background(Color.appSurface)
        .sheet(isPresented: $mapOpen) {
            LocationPickerSheet(address: $address)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("客戶名稱重複", isPresented: $showingDuplicateAlert) {
            Button("好") {}
        } message: {
            Text("「\(name.trimmingCharacters(in: .whitespaces))」已經在客戶簿內。請改名或直接到列表編輯既有資料。")
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            Button("取消") { dismiss() }
                .foregroundStyle(Color.inkSoft)
            Spacer()
            Text("新增客戶")
                .font(AppFont.sans(17, weight: .bold))
                .foregroundStyle(Color.ink)
            Spacer()
            Button("儲存") { save() }
                .foregroundStyle(canSave ? Color.accent : Color.inkFaint)
                .font(AppFont.sans(15, weight: .bold))
                .disabled(!canSave)
        }
        .font(AppFont.sans(15))
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
        }
    }

    // MARK: - 大 avatar 預覽

    private var avatarPreview: some View {
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        return ZStack {
            Circle()
                .fill(hasName ? Color.accent.opacity(0.14) : Color.surfaceAlt)
                .overlay(
                    Circle().strokeBorder(
                        hasName ? Color.accent : Color.borderStrong,
                        style: StrokeStyle(lineWidth: 1.5,
                                           dash: hasName ? [] : [4, 4])
                    )
                )

            if hasName {
                Text(String(name.prefix(1)))
                    .font(AppFont.sans(28, weight: .bold))
                    .foregroundStyle(Color.accent)
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.inkFaint)
            }
        }
        .frame(width: 72, height: 72)
        .animation(.default, value: hasName)
        .frame(maxWidth: .infinity)
    }

    // MARK: - 地圖按鈕

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
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.appBorder, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 備註 textarea

    private var notesEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $notes)
                .font(AppFont.sans(14))
                .foregroundStyle(Color.ink)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 80)
                .background(Color.appSurface,
                            in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .strokeBorder(Color.appBorder, lineWidth: 1.5)
                )
            if notes.isEmpty {
                Text("例：張先生介紹、喜歡北歐風、付款乾脆⋯")
                    .font(AppFont.sans(14))
                    .foregroundStyle(Color.inkFaint)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - 底部提示

    private var hintCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.accent)
            Text("加進來後，未來的報價單只要輸入名字，地址跟電話會自動帶入。統計頁也會自動歸戶這位客戶的累計營收。")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.inkSoft)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceAlt,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(Color.appBorder)
        )
    }

    // MARK: - 儲存

    private func save() {
        guard canSave else { return }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if existingNames.contains(trimmed) {
            showingDuplicateAlert = true
            return
        }
        let client = Client(
            name:    trimmed,
            phone:   phone.trimmingCharacters(in: .whitespaces),
            email:   email.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            notes:   notes
        )
        onSave(client)
        dismiss()
    }
}

#Preview {
    Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            NewClientSheet { _ in }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
}
