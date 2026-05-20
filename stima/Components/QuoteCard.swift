import SwiftUI

/// 報價單列表卡片。主要在 HomeScreen 顯示，未來客戶詳情頁的歷史報價也會用。
struct QuoteCard: View {
    let quote: Quote
    let onTap: () -> Void

    var body: some View {
        AppCard(onTap: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                topRow
                    .padding(.bottom, 6)
                locationRow
                    .padding(.bottom, 12)
                AppDivider()
                    .padding(.bottom, 10)
                bottomRow
            }
        }
    }

    // 客戶名 + 狀態 + 日期
    private var topRow: some View {
        HStack(alignment: .top, spacing: 10) {
            HStack(spacing: 8) {
                Text(quote.clientName)
                    .font(AppFont.sans(16, weight: .bold))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)
                StatusBadge(quote.quoteStatus)
            }
            Spacer(minLength: 8)
            Text(Self.dateFormatter.string(from: quote.date))
                .font(AppFont.mono(12))
                .foregroundStyle(Color.inkSoft)
        }
    }

    // 地點 + 分類
    private var locationRow: some View {
        HStack(spacing: 4) {
            Image(systemName: "mappin")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.inkSoft)
            Text(quote.location)
                .font(AppFont.sans(13))
                .foregroundStyle(Color.inkSoft)
                .lineLimit(1)
            if let folder = quote.folder {
                Text("·")
                    .foregroundStyle(Color.inkFaint)
                    .padding(.horizontal, 2)
                Image(systemName: "folder")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.inkSoft)
                Text(folder)
                    .font(AppFont.sans(13))
                    .foregroundStyle(Color.inkSoft)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    // 項目數 + 總金額
    private var bottomRow: some View {
        HStack {
            Text("\(quote.items.count) 個項目")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.inkSoft)
            Spacer()
            Money(quote.total, size: 18, color: .accent)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

#Preview {
    ScrollView {
        VStack(spacing: 10) {
            ForEach(PreviewData.makeSampleQuotes(), id: \.id) { q in
                QuoteCard(quote: q) { }
            }
        }
        .padding()
    }
    .background(Color.bgPaper)
}
