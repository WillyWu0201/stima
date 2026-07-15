import SwiftUI
import SwiftData
import PhotosUI

/// 畫面 13 · PDF 模板自訂
/// 從 Settings → 報價單模板 push 進來。右上「預覽」按鈕開 PDFPreviewSheet 看效果。
struct PDFTemplateScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Query private var templates: [PDFTemplate]
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    @State private var previewOpen = false

    /// 取目前 template，沒有就建一個（只用在 .onAppear 內）。
    /// 注意：不要在 computed property 內 insert，否則 SwiftUI re-render 時會
    /// 每次都產生新 row，PDFTemplate 列表會爆。改用 onAppear ensure 一次。
    private var template: PDFTemplate? {
        templates.first
    }

    private func ensureTemplate() {
        guard templates.isEmpty else { return }
        modelContext.insert(PDFTemplate())
    }

    private static let brandColors: [String] = [
        "#C9522A",  // brick
        "#1A1A1A",  // black
        "#2A6FDB",  // blue
        "#1F8A5B",  // green
        "#7A5AE0",  // purple
    ]

    private static let validDayOptions: [Int] = [7, 14, 30, 60, 90]
    private static let fontOptions: [String] = ["黑體", "明體", "楷體"]

    var body: some View {
        VStack(spacing: 0) {
            header
            if template != nil {
                content
            } else {
                ProgressView()
                    .frame(maxHeight: .infinity)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { ensureTemplate() }
        .sheet(isPresented: $previewOpen) {
            if let quote = quotes.first {
                PDFPreviewSheet(quote: quote)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let t = template {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    SectionTitle("商號識別")
                    businessCard(t)

                    SectionTitle("Logo 與印章")
                    uploadCard(t)

                    SectionTitle("聯絡資訊")
                    contactCard(t)

                    SectionTitle("付款條件 & 簽名")
                    paymentCard(t)

                    SectionTitle("外觀")
                    appearanceCard(t)

                    if !settings.isPro {
                        proLimitCard
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 14)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        AppHeader(
            title: "報價單模板",
            subtitle: "設定",
            accent: true,
            onBack: { dismiss() }
        ) {
            Button("預覽") {
                previewOpen = true
            }
            .font(AppFont.sans(15, weight: .semibold))
            .foregroundStyle(quotes.isEmpty ? Color.accentSurfaceInk.opacity(0.4) : Color.accent2)
            .disabled(quotes.isEmpty)
        }
    }

    // MARK: - Cards

    private func businessCard(_ template: PDFTemplate) -> some View {
        @Bindable var t = template
        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("公司／工作室名稱（抬頭）") {
                    AppTextField(text: $t.businessName,
                                 placeholder: "例：Stima",
                                 maxLength: 50)
                }
                labeledField("標語／slogan（可空白）") {
                    AppTextField(text: $t.slogan,
                                 placeholder: "例：交期不拖、價錢實在",
                                 maxLength: 40)
                }
            }
        }
    }

    private func uploadCard(_ template: PDFTemplate) -> some View {
        @Bindable var t = template
        return AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    UploadSlot(systemImage: "building.2",
                               label: "商號 Logo", hint: "左上角",
                               data: $t.logoData)
                    UploadSlot(systemImage: "seal",
                               label: "印章", hint: "右下簽章",
                               data: $t.stampData)
                }
                Text("支援 PNG（建議透明背景）、JPG。最大 2MB / 邊長 1200px。")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkFaint)
            }
        }
    }

    private func contactCard(_ template: PDFTemplate) -> some View {
        @Bindable var t = template
        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("電話", systemImage: "phone") {
                    AppTextField(text: $t.phone, placeholder: "0912-345-678",
                                 maxLength: 20)
                        .keyboardType(.phonePad)
                }
                labeledField("Email") {
                    AppTextField(text: $t.email, placeholder: "chen@example.com",
                                 maxLength: 80)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                labeledField("統編／營業地址") {
                    AppTextField(text: $t.address,
                                 placeholder: "例：統編 12345678 / 台北市信義區⋯",
                                 maxLength: 120)
                }
            }
        }
    }

    private func paymentCard(_ template: PDFTemplate) -> some View {
        @Bindable var t = template
        return AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("付款條件") {
                    paymentTermsEditor(text: $t.paymentTerms)
                }
                labeledField("收款資訊（顯示在請款單）") {
                    paymentTermsEditor(text: $t.paymentInfo,
                                       placeholder: "例：匯款 玉山銀行(808) 1234-567-890\nLINE Pay 掃描 QR Code\n現金請電 0912-345-678")
                    Text("一行一項；留空的話請款單就不顯示付款方式。")
                        .font(AppFont.sans(11))
                        .foregroundStyle(Color.inkFaint)
                }
                labeledField("有效期限（天）") {
                    HStack(spacing: 4) {
                        ForEach(Self.validDayOptions, id: \.self) { d in
                            inkChip("\(d) 天", isActive: t.validDays == d) {
                                t.validDays = d
                            }
                        }
                    }
                }

                Button {
                    t.showSignatureLine.toggle()
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(t.showSignatureLine ? Color.accent : Color.appSurface)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(t.showSignatureLine
                                                      ? Color.accent : Color.borderStrong,
                                                      lineWidth: 1.5)
                                )
                            if t.showSignatureLine {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        Text("顯示甲乙方簽名欄（給客戶簽名用）")
                            .font(AppFont.sans(13))
                            .foregroundStyle(Color.ink)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.surfaceAlt,
                                in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Color.appBorder)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func appearanceCard(_ template: PDFTemplate) -> some View {
        @Bindable var t = template
        return AppCard {
            VStack(alignment: .leading, spacing: 14) {
                labeledField("主色（PDF 上的強調色）") {
                    HStack(spacing: 10) {
                        ForEach(Self.brandColors, id: \.self) { hex in
                            ColorSwatch(hex: hex,
                                        isActive: t.brandColor == hex) {
                                t.brandColor = hex
                            }
                        }
                    }
                }
                labeledField("字體") {
                    HStack(spacing: 6) {
                        ForEach(Self.fontOptions, id: \.self) { f in
                            Button {
                                t.fontStyle = f
                            } label: {
                                Text(LocalizedStringKey(f))
                                    .font(AppFont.sans(13, weight: .semibold))
                                    .foregroundStyle(t.fontStyle == f ? .white : Color.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        t.fontStyle == f ? Color.ink : Color.appSurface,
                                        in: RoundedRectangle(cornerRadius: Radius.card,
                                                             style: .continuous)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Radius.card,
                                                         style: .continuous)
                                            .strokeBorder(t.fontStyle == f
                                                          ? Color.ink : Color.appBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var proLimitCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("免費版限制")
                    .font(AppFont.sans(14, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text("每月 3 張報價單，PDF 含浮水印。升級 Pro 解鎖無限張、自訂模板、移除浮水印。")
                    .font(AppFont.sans(12))
                    .foregroundStyle(Color.inkSoft)
                    .lineSpacing(3)
            }
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceAlt,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(Color.accent)
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    private func labeledField<C: View>(_ label: String,
                                       systemImage: String? = nil,
                                       @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 11, weight: .semibold))
                }
                Text(LocalizedStringKey(label))
            }
            .font(AppFont.sans(12, weight: .semibold))
            .foregroundStyle(Color.inkSoft)
            content()
        }
    }

    private func paymentTermsEditor(text: Binding<String>,
                                    placeholder: String = "例：簽約付 30%，完工驗收付 60%，保固期滿付 10%") -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: text)
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
            if text.wrappedValue.isEmpty {
                Text(LocalizedStringKey(placeholder))
                    .font(AppFont.sans(14))
                    .foregroundStyle(Color.inkFaint)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }
        }
    }

    private func inkChip(_ label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.sans(13, weight: .semibold))
                .foregroundStyle(isActive ? .white : Color.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isActive ? Color.ink : Color.appSurface, in: Capsule())
                .overlay(
                    Capsule().strokeBorder(isActive ? Color.ink : Color.appBorder,
                                           lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Upload slot

private struct UploadSlot: View {
    let systemImage: String
    let label: String
    let hint: String
    @Binding var data: Data?

    @State private var selection: PhotosPickerItem?

    private var hasFile: Bool { data != nil }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PhotosPicker(selection: $selection, matching: .images) {
                content
            }
            .buttonStyle(.plain)

            if hasFile {
                Button {
                    data = nil
                    selection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.appSurface, Color.inkSoft)
                }
                .buttonStyle(.plain)
                .padding(6)
                .accessibilityLabel("移除圖片")
            }
        }
        .onChange(of: selection) { _, item in
            Task { await load(item) }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 6) {
            preview
                .frame(width: 48, height: 48)

            Text(LocalizedStringKey(label))
                .font(AppFont.sans(13, weight: .semibold))
                .foregroundStyle(Color.ink)
            Text(LocalizedStringKey(hint))
                .font(AppFont.sans(10))
                .foregroundStyle(Color.inkSoft)
            Text(hasFile ? "✓ 已上傳" : "+ 點此上傳")
                .font(AppFont.sans(11, weight: .semibold))
                .foregroundStyle(hasFile ? Color.positive : Color.accent)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color.appSurface,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .foregroundStyle(hasFile ? Color.accent : Color.borderStrong)
        )
    }

    @ViewBuilder
    private var preview: some View {
        if let data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.accent.opacity(0.3), lineWidth: 1))
        } else {
            ZStack {
                Circle().fill(Color.surfaceAlt)
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Color.inkFaint)
            }
        }
    }

    private func load(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let loaded = try? await item.loadTransferable(type: Data.self) {
            data = loaded
        }
    }
}

// MARK: - Color swatch

private struct ColorSwatch: View {
    let hex: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(parseColor(hex))
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(Color.ink, lineWidth: isActive ? 2 : 0)
                        .padding(-4)
                )
                .padding(4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hex)
    }

    private func parseColor(_ hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt(s, radix: 16) else { return Color.accent }
        return Color(red: Double((v >> 16) & 0xFF) / 255,
                     green: Double((v >> 8)  & 0xFF) / 255,
                     blue: Double(v         & 0xFF) / 255)
    }
}

#Preview {
    NavigationStack {
        PDFTemplateScreen()
    }
    .environment(PreviewData.settings)
    .modelContainer(PreviewData.container)
}
