import Testing
import Foundation
@testable import stima

@Suite("TierGate · 免費／PRO 配額判斷")
struct TierGateTests {

    private func makeQuote(monthsAgo: Int = 0) -> Quote {
        let date = Calendar.current.date(byAdding: .month, value: -monthsAgo, to: .now) ?? .now
        return Quote(clientName: "客戶", location: "地點", date: date)
    }

    @Test
    func proUserAlwaysAllowed() {
        let quotes = (0..<10).map { _ in makeQuote() }
        #expect(TierGate.canCreateQuote(isPro: true, quotes: quotes))
    }

    @Test
    func freeUserUnderLimit() {
        let quotes = (0..<TierConfig.freeMonthlyQuoteLimit - 1).map { _ in makeQuote() }
        #expect(TierGate.canCreateQuote(isPro: false, quotes: quotes))
    }

    @Test
    func freeUserAtLimit() {
        let quotes = (0..<TierConfig.freeMonthlyQuoteLimit).map { _ in makeQuote() }
        #expect(!TierGate.canCreateQuote(isPro: false, quotes: quotes))
    }

    @Test
    func freeUserOverLimit() {
        let quotes = (0..<(TierConfig.freeMonthlyQuoteLimit + 5)).map { _ in makeQuote() }
        #expect(!TierGate.canCreateQuote(isPro: false, quotes: quotes))
    }

    @Test("上個月的 quotes 不算進這個月配額")
    func lastMonthDoesntCount() {
        let quotes = (0..<10).map { _ in makeQuote(monthsAgo: 1) }
        #expect(TierGate.canCreateQuote(isPro: false, quotes: quotes))
    }

    @Test
    func currentMonthQuoteCountIgnoresOtherMonths() {
        let thisMonth = (0..<2).map { _ in makeQuote() }
        let lastMonth = (0..<5).map { _ in makeQuote(monthsAgo: 1) }
        let count = TierGate.currentMonthQuoteCount(quotes: thisMonth + lastMonth)
        #expect(count == 2)
    }

    @Test
    func remainingFreeQuotesForProIsNil() {
        let quotes = (0..<2).map { _ in makeQuote() }
        #expect(TierGate.remainingFreeQuotes(isPro: true, quotes: quotes) == nil)
    }

    @Test
    func remainingFreeQuotesCountsDown() {
        let quotes = (0..<2).map { _ in makeQuote() }
        #expect(TierGate.remainingFreeQuotes(isPro: false, quotes: quotes)
                == TierConfig.freeMonthlyQuoteLimit - 2)
    }

    @Test
    func remainingFreeQuotesNeverNegative() {
        let quotes = (0..<(TierConfig.freeMonthlyQuoteLimit + 5)).map { _ in makeQuote() }
        #expect(TierGate.remainingFreeQuotes(isPro: false, quotes: quotes) == 0)
    }
}
