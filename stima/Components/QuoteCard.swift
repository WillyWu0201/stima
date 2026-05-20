import SwiftUI

/// 報價單列表卡片。主要在 HomeScreen 顯示，未來客戶詳情頁的歷史報價也會用。
/// 本身不負責點擊行為，由外層 NavigationLink 或 Button 處理。
struct QuoteCard: View {
    let quote: Quote

    var body: some View {
        AppCard {
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

    // 地點 + 分類（inline，超寬自動換行完整顯示）
    private var locationRow: some View {
        locationText
            .font(AppFont.sans(13))
            .foregroundStyle(Color.inkSoft)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var locationText: Text {
        if let folder = quote.folder {
            Text("\(Image(systemName: "mappin"))  \(quote.location)   ·   \(Image(systemName: "folder"))  \(folder)")
        } else {
            Text("\(Image(systemName: "mappin"))  \(quote.location)")
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

#Preview("一般") {
    ScrollView {
        VStack(spacing: 10) {
            ForEach(PreviewData.makeSampleQuotes(), id: \.id) { q in
                QuoteCard(quote: q)
            }
        }
        .padding()
    }
    .background(Color.bgPaper)
}

#Preview("長地址") {
    let quotes = PreviewData.makeSampleQuotes()
    quotes[0].location = "新北市板橋區文化路二段 150 號 12 樓之 3"
    quotes[1].location = "高雄市鼓山區美術東二路 88 巷 5 弄 12 號"
    return ScrollView {
        VStack(spacing: 10) {
            ForEach(quotes, id: \.id) { q in
                QuoteCard(quote: q)
            }
        }
        .padding()
    }
    .background(Color.bgPaper)
}
