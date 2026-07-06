import Testing
@testable import stima

@Suite("TierConfig · PRO 功能閘門")
struct TierConfigTests {

    @Test("免費使用者：每個 PRO 功能都被擋", arguments: TierConfig.ProFeature.allCases)
    func freeUserGated(_ feature: TierConfig.ProFeature) {
        #expect(TierConfig.requires(feature, isPro: false) == true)
    }

    @Test("PRO 使用者：每個功能都放行", arguments: TierConfig.ProFeature.allCases)
    func proUserUnlocked(_ feature: TierConfig.ProFeature) {
        #expect(TierConfig.requires(feature, isPro: true) == false)
    }
}
