import SwiftUI
import SwiftData

/// 畫面 13 · PDF 模板自訂
/// 從 Settings → 報價單模板 push 進來。右上「預覽」按鈕開 PDFPreviewSheet 看效果。
struct PDFTemplateScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Query private var templates: [PDFTemplate]
    @Query(sort: \Quote.date, order: .reverse) private var quotes: [Quote]

    @State private var previewOpen = false

    /// 預設沒有 template 就建一個，並 insert 進 model context。
    private var template: PDFTemplate {
        if let t = templates.first { return t }
        let new = PDFTemplate()
        modelContext.insert(new)
        return new
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
        @Bindable var t = template
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.cardGap) {
                    SectionTitle("商號識別")
                    businessCard(t: $t)

                    SectionTitle("Logo 與印章")
                    uploadCard

                    SectionTitle("聯絡資訊")
                    contactCard(t: $t)

                    SectionTitle("付款條件 & 簽名")
                    paymentCard(t: $t)

                    SectionTitle("外觀")
                    appearanceCard(t: $t)

                    if !settings.isPro {
                        proLimitCard
                    }
                }
                .padding(.horizontal, Spacing.screenH)
                .padding(.top, 14)
                .padding(.bottom, 40)
            }
        }
        .background(Color.bgPaper)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $previewOpen) {
            if let quote = quotes.first {
                PDFPreviewSheet(quote: quote)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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

    private func businessCard(t: Binding<PDFTemplate>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("公司／工作室名稱（抬頭）") {
                    AppTextField(text: t.businessName, placeholder: "例：大發工程行")
                }
                labeledField("標語／slogan（可空白）") {
                    AppTextField(text: t.slogan, placeholder: "例：交期不拖、價錢實在")
                }
            }
        }
    }

    private var uploadCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    UploadSlot(systemImage: "building.2",
                               label: "商號 Logo", hint: "左上角", hasFile: false)
                    UploadSlot(systemImage: "seal",
                               label: "印章", hint: "右下簽章", hasFile: false)
                }
                Text("支援 PNG（建議透明背景）、JPG。最大 2MB / 邊長 1200px。")
                    .font(AppFont.sans(11))
                    .foregroundStyle(Color.inkFaint)
            }
        }
    }

    private func contactCard(t: Binding<PDFTemplate>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("電話", systemImage: "phone") {
                    AppTextField(text: t.phone, placeholder: "0912-345-678")
                        .keyboardType(.phonePad)
                }
                labeledField("Email") {
                    AppTextField(text: t.email, placeholder: "chen@example.com")
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                labeledField("統編／營業地址") {
                    AppTextField(text: t.address,
                                 placeholder: "例：統編 12345678 / 台北市信義區⋯")
                }
            }
        }
    }

    private func paymentCard(t: Binding<PDFTemplate>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                labeledField("付款條件") {
                    paymentTermsEditor(text: t.paymentTerms)
                }
                labeledField("有效期限（天）") {
                    HStack(spacing: 4) {
                        ForEach(Self.validDayOptions, id: \.self) { d in
                            inkChip("\(d) 天", isActive: t.validDays.wrappedValue == d) {
                                t.validDays.wrappedValue = d
                            }
                        }
                    }
                }

                Button {
                    t.showSignatureLine.wrappedValue.toggle()
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(t.showSignatureLine.wrappedValue ? Color.accent : Color.appSurface)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(t.showSignatureLine.wrappedValue
                                                      ? Color.accent : Color.borderStrong,
                                                      lineWidth: 1.5)
                                )
                            if t.showSignatureLine.wrappedValue {
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

    private func appearanceCard(t: Binding<PDFTemplate>) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                labeledField("主色（PDF 上的強調色）") {
                    HStack(spacing: 10) {
                        ForEach(Self.brandColors, id: \.self) { hex in
                            ColorSwatch(hex: hex,
                                        isActive: t.brandColor.wrappedValue == hex) {
                                t.brandColor.wrappedValue = hex
                            }
                        }
                    }
                }
                labeledField("字體") {
                    HStack(spacing: 6) {
                        ForEach(Self.fontOptions, id: \.self) { f in
                            Button {
                                t.fontStyle.wrappedValue = f
                            } label: {
                                Text(f)
                                    .font(AppFont.sans(13, weight: .semibold))
                                    .foregroundStyle(t.fontStyle.wrappedValue == f ? .white : Color.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        t.fontStyle.wrappedValue == f ? Color.ink : Color.appSurface,
                                        in: RoundedRectangle(cornerRadius: Radius.card,
                                                             style: .continuous)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Radius.card,
                                                         style: .continuous)
                                            .strokeBorder(t.fontStyle.wrappedValue == f
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
                Text(label)
            }
            .font(AppFont.sans(12, weight: .semibold))
            .foregroundStyle(Color.inkSoft)
            content()
        }
    }

    private func paymentTermsEditor(text: Binding<String>) -> some View {
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
                Text("例：簽約付 30%，完工驗收付 60%，保固期滿付 10%")
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
    let hasFile: Bool

    var body: some View {
        Button {
            // TODO: PhotosPicker 接 PNG/JPG
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(hasFile ? Color.accent.opacity(0.14) : Color.surfaceAlt)
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(hasFile ? Color.accent : Color.inkFaint)
                }
                .frame(width: 48, height: 48)

                Text(label)
                    .font(AppFont.sans(13, weight: .semibold))
                    .foregroundStyle(Color.ink)
                Text(hint)
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
        .buttonStyle(.plain)
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
