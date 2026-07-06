import SwiftUI
import SwiftData

/// 畫面 14 · PDF 預覽
/// 從 Detail / PDFTemplate 的「預覽 PDF」按鈕召喚的 page-sheet。
/// 預覽用 QuotePaper 渲染螢幕寬版本，分享/儲存按下時 PDFExporter 用 A4 寬重新渲染成 PDF。
struct PDFPreviewSheet: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var settings
    @Query private var templates: [PDFTemplate]

    @State private var pdfURL: URL?
    @State private var renderFailed = false

    private var template: PDFTemplate? { templates.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                paper
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 14)
            }
            .background(Color(red: 0.898, green: 0.886, blue: 0.863))  // 桌面暖灰
            .navigationTitle("PDF 預覽")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                footerActions
            }
        }
        .tint(.accent)
        .task {
            await render()
        }
        .alert("PDF 產生失敗", isPresented: $renderFailed) {
            Button("重試") {
                Task { await render() }
            }
            Button("關閉", role: .cancel) { dismiss() }
        } message: {
            Text("無法產生這份報價單的 PDF。請再試一次，若持續失敗請重新啟動 app。")
        }
    }

    private func render() async {
        let url = PDFExporter.renderQuote(
            quote,
            template:    template,
            masterName:  settings.masterName,
            watermarked: !settings.isPro,
            currencySymbol: settings.currencySymbol
        )
        if let url {
            pdfURL = url
            renderFailed = false
        } else {
            pdfURL = nil
            renderFailed = true
        }
    }

    // MARK: - Paper preview（用 QuotePaper 渲染，包個 shadow + rounded corner 當 chrome）

    private var paper: some View {
        QuotePaper(
            quote:       quote,
            template:    template,
            masterName:  settings.masterName,
            watermarked: !settings.isPro,
            currencySymbol: settings.currencySymbol
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)
    }

    // MARK: - Footer

    private var footerActions: some View {
        HStack(spacing: 10) {
            if let pdfURL {
                ShareLink(item: pdfURL,
                          subject: Text("報價單 · \(quote.clientName)"),
                          message: Text(ShareMessage.forQuote(quote, masterName: settings.masterName, currencySymbol: settings.currencySymbol))) {
                    secondaryButtonLabel(title: "分享", systemImage: "square.and.arrow.up")
                }
                ShareLink(item: pdfURL,
                          subject: Text("報價單 · \(quote.clientName)")) {
                    primaryButtonLabel(title: "儲存 PDF", systemImage: "doc.text")
                }
            } else {
                // 還沒渲染好（< 1 秒）就顯示 disabled 版
                secondaryButtonLabel(title: "分享", systemImage: "square.and.arrow.up")
                    .opacity(0.5)
                primaryButtonLabel(title: "儲存 PDF", systemImage: "doc.text")
                    .opacity(0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(Color(red: 0.898, green: 0.886, blue: 0.863))
        .overlay(alignment: .top) {
            Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
        }
    }

    // MARK: - Button labels（給 ShareLink 用，跟 SecondaryButton/PrimaryButton 視覺一致）

    private func secondaryButtonLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(AppFont.sans(15, weight: .semibold))
        }
        .foregroundStyle(Color.ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.appSurface,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .strokeBorder(Color.borderStrong, lineWidth: 1.5)
        )
    }

    private func primaryButtonLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(AppFont.sans(16, weight: .semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.accent,
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}

#Preview("免費版（有浮水印）") {
    let quote = PreviewData.makeSampleQuotes()[0]
    return Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PDFPreviewSheet(quote: quote)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .environment(PreviewData.settings)
        .modelContainer(PreviewData.container)
}

#Preview("PRO（無浮水印）") {
    let quote = PreviewData.makeSampleQuotes()[0]
    return Color.bgPaper
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PDFPreviewSheet(quote: quote)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .environment(PreviewData.settingsPro)
        .modelContainer(PreviewData.container)
}
