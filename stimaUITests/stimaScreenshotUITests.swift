import XCTest

/// 逐一走訪每個畫面並截圖（XCTAttachment），供人工檢視版面。
/// 目的是「拍到畫面」而非嚴格驗證 → continueAfterFailure = true + 防禦式點擊，
/// 單一畫面若有問題也不擋其他畫面截圖。跑法：serial 單一 sim。
final class stimaScreenshotUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
    }

    // MARK: - Helpers

    @MainActor private func snap(_ name: String) {
        let a = XCTAttachment(screenshot: app.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }
    @MainActor private func stC(_ t: String) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", t)).firstMatch
    }
    @MainActor private func btnC(_ t: String) -> XCUIElement {
        app.buttons.containing(NSPredicate(format: "label CONTAINS %@", t)).firstMatch
    }
    @MainActor private func tapIfPresent(_ e: XCUIElement, timeout: TimeInterval = 6) {
        guard e.waitForExistence(timeout: timeout) else { return }
        var n = 0
        while !e.isHittable && n < 8 { app.swipeUp(); n += 1 }
        if e.isHittable { e.tap() }
    }
    private func launchSeeded() {
        app.launchArguments = ["--uitest-reset", "--uitest-inmemory", "--uitest-seed", "--uitest-onboarded"]
        app.launch()
    }
    private func launchSeededPro() {
        app.launchArguments = ["--uitest-reset", "--uitest-inmemory", "--uitest-seed", "--uitest-onboarded", "--uitest-pro"]
        app.launch()
    }

    // MARK: - Onboarding（不帶 --uitest-onboarded）

    @MainActor
    func testShotsOnboarding() throws {
        app.launchArguments = ["--uitest-reset", "--uitest-inmemory"]
        app.launch()
        _ = stC("v2.0").waitForExistence(timeout: 10);            snap("01-Splash")
        tapIfPresent(btnC("開工"))
        _ = stC("它能幫你做什麼").waitForExistence(timeout: 6);     snap("02-Intro")
        tapIfPresent(btnC("看起來不錯"))
        _ = stC("我們來試做").waitForExistence(timeout: 6);         snap("03-TutorialCTA")
    }

    // MARK: - 三個 tab

    @MainActor
    func testShotsTabs() throws {
        launchSeeded()
        _ = stC("我的報價單").waitForExistence(timeout: 10);        snap("10-Home")
        app.swipeUp();                                            snap("10b-Home-scroll")
        app.tabBars.buttons["統計"].tap()
        _ = stC("營運統計").waitForExistence(timeout: 10);          snap("20-Stats")
        app.swipeUp();                                            snap("20b-Stats-scroll")
        app.swipeUp();                                            snap("20c-Stats-scroll2")
        app.tabBars.buttons["設定"].tap()
        _ = stC("設定").waitForExistence(timeout: 10);             snap("30-Settings")
        app.swipeUp();                                            snap("30b-Settings-scroll")
        app.swipeUp();                                            snap("30c-Settings-scroll2")
    }

    // MARK: - 報價單詳情 + PDF 預覽

    @MainActor
    func testShotsQuoteDetail() throws {
        launchSeeded()
        tapIfPresent(stC("王先生"), timeout: 10)
        _ = btnC("預覽 PDF").waitForExistence(timeout: 6);         snap("40-QuoteDetail")
        app.swipeUp();                                            snap("40b-QuoteDetail-scroll")
        tapIfPresent(btnC("預覽 PDF"))
        _ = stC("PDF 預覽").waitForExistence(timeout: 10);         snap("41-PDFPreview")
    }

    // MARK: - 客戶簿 + 客戶詳情

    @MainActor
    func testShotsContacts() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("客戶簿"))
        _ = stC("林太太").waitForExistence(timeout: 10);           snap("50-Contacts")
    }

    @MainActor
    func testShotsClientDetail() throws {
        launchSeeded()
        // 從 報價單詳情 →「查看客戶」進客戶詳情（單一連結，比點客戶簿卡片穩定）
        tapIfPresent(stC("林太太"), timeout: 10)   // Home 上林太太（已收款）的報價單
        _ = btnC("預覽 PDF").waitForExistence(timeout: 6)
        tapIfPresent(btnC("查看客戶"))
        _ = stC("累計營收").waitForExistence(timeout: 6);          snap("51-ClientDetail")
    }

    // MARK: - 新增客戶 sheet

    @MainActor
    func testShotsNewClient() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("客戶簿"))
        _ = stC("林太太").waitForExistence(timeout: 10)
        if app.buttons["新增客戶"].waitForExistence(timeout: 6) { app.buttons["新增客戶"].tap() }
        _ = stC("新增客戶").waitForExistence(timeout: 6);          snap("52-NewClientSheet")
    }

    // MARK: - 地圖選點 sheet（新增客戶 → 地圖）

    @MainActor
    func testShotsLocationPicker() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("客戶簿"))
        _ = stC("林太太").waitForExistence(timeout: 10)
        if app.buttons["新增客戶"].waitForExistence(timeout: 6) { app.buttons["新增客戶"].tap() }
        tapIfPresent(btnC("地圖"))
        _ = stC("從地圖選地點").waitForExistence(timeout: 8);      snap("53-LocationPicker")
    }

    // MARK: - 幣別切換驗證（切越南盾 → 金額應變 ₫）

    @MainActor
    func testShotsCurrencyVND() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        _ = stC("設定").waitForExistence(timeout: 8)
        tapIfPresent(stC("貨幣"))
        tapIfPresent(btnC("越南盾"))          // confirmationDialog：「₫ 越南盾」
        app.tabBars.buttons["報價單"].tap()
        _ = stC("我的報價單").waitForExistence(timeout: 8);        snap("A0-Currency-Home-VND")
        tapIfPresent(stC("王先生"), timeout: 8)
        _ = btnC("預覽 PDF").waitForExistence(timeout: 6);        snap("A1-Currency-Detail-VND")
        tapIfPresent(btnC("預覽 PDF"))
        _ = stC("PDF 預覽").waitForExistence(timeout: 8);         snap("A2-Currency-PDF-VND")
    }

    // MARK: - PDF 字體驗證（選明體 / 楷體 → 預覽 PDF 應變字體）

    @MainActor
    func testShotsPDFFont() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("報價單模板"))
        _ = app.buttons["預覽"].waitForExistence(timeout: 8)
        selectFont("明體")
        tapIfPresent(app.buttons["預覽"])
        _ = stC("PDF 預覽").waitForExistence(timeout: 8);          snap("B1-PDF-Font-明體")
        tapIfPresent(btnC("完成"))
        selectFont("楷體")
        tapIfPresent(app.buttons["預覽"])
        _ = stC("PDF 預覽").waitForExistence(timeout: 8);          snap("B2-PDF-Font-楷體")
    }

    /// 字體選擇器在模板頁最底部，往下捲到「字體」chip 再點。
    @MainActor private func selectFont(_ name: String) {
        let btn = app.buttons[name]
        var n = 0
        while !btn.isHittable && n < 15 { app.swipeUp(); n += 1 }
        if btn.isHittable { btn.tap() }
    }

    // MARK: - PDF 模板

    @MainActor
    func testShotsPDFTemplate() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("報價單模板"))
        _ = app.buttons["預覽"].waitForExistence(timeout: 10);     snap("60-PDFTemplate")
        app.swipeUp();                                            snap("60b-PDFTemplate-scroll")
        app.swipeUp();                                            snap("60c-PDFTemplate-scroll2")
    }

    // MARK: - Paywall

    @MainActor
    func testShotsPaywall() throws {
        launchSeeded()
        app.tabBars.buttons["設定"].tap()
        tapIfPresent(stC("升級到Stima PRO"))
        _ = stC("Stima PRO").waitForExistence(timeout: 10);       snap("70-Paywall")
        app.swipeUp();                                            snap("70b-Paywall-scroll")
    }

    // MARK: - 項目詳情

    @MainActor
    func testShotsItemDetail() throws {
        launchSeeded()
        app.tabBars.buttons["統計"].tap()
        _ = stC("營運統計").waitForExistence(timeout: 10)
        tapIfPresent(stC("木作天花板"))
        _ = stC("最近單價").waitForExistence(timeout: 6);          snap("80-ItemDetail")
        app.swipeUp();                                            snap("80b-ItemDetail-scroll")
    }

    // MARK: - 新報價流程

    @MainActor
    func testShotsNewQuoteFlow() throws {
        launchSeeded()
        tapIfPresent(app.buttons["新增報價單"], timeout: 10)
        _ = app.textFields["例：王先生、林太太"].waitForExistence(timeout: 6); snap("90-NewQuoteInfo")
        let cf = app.textFields["例：王先生、林太太"]
        if cf.exists { cf.tap(); cf.typeText("測試客戶") }
        tapIfPresent(btnC("下一步:加項目"))
        _ = stC("加項目").waitForExistence(timeout: 6);            snap("91-NewQuoteItems")
        tapIfPresent(btnC("加項目"))
        _ = stC("挑項目").waitForExistence(timeout: 6);            snap("92-ItemPicker")
        tapIfPresent(stC("自訂"))
        _ = stC("加進你的項目庫").waitForExistence(timeout: 4);     snap("93-CustomItemForm")
    }

    // MARK: - 確認出單（3/3）

    @MainActor
    func testShotsReview() throws {
        launchSeeded()
        tapIfPresent(app.buttons["新增報價單"], timeout: 10)
        let cf = app.textFields["例：王先生、林太太"]
        _ = cf.waitForExistence(timeout: 6)
        if cf.exists { cf.tap(); cf.typeText("測試客戶") }
        tapIfPresent(btnC("下一步:加項目"))
        _ = stC("加項目").waitForExistence(timeout: 6)
        tapIfPresent(btnC("加項目"))
        _ = stC("挑項目").waitForExistence(timeout: 6)
        tapIfPresent(stC("拆除磁磚"))   // 常用 tab 預設，點項目加入（happy-path 已驗證可行）
        if app.buttons["關閉"].waitForExistence(timeout: 3) { app.buttons["關閉"].tap() }
        tapIfPresent(btnC("下一步"))
        _ = stC("確認出單").waitForExistence(timeout: 6);          snap("94-NewQuoteReview")
        app.swipeUp();                                            snap("94b-Review-scroll")
    }

    // MARK: - 統計 · 淨利卡（PRO 專屬 · --uitest-pro）

    @MainActor
    func testShotsStatsProNetProfit() throws {
        launchSeededPro()
        app.tabBars.buttons["統計"].tap()
        _ = stC("營運統計").waitForExistence(timeout: 10)
        // 淨利卡在 mini stats 下方，往下捲一點確保入鏡
        _ = stC("淨利率").waitForExistence(timeout: 6)
        XCTAssertTrue(stC("淨利率").exists, "PRO 用戶的統計頁應顯示淨利卡")
        snap("21-Stats-PRO-NetProfit")
    }

    // MARK: - 請款單 · 付款方式（吃 PDF 模板設定值，非寫死假帳號）

    @MainActor
    func testShotsInvoicePayment() throws {
        launchSeeded()
        tapIfPresent(stC("王先生"), timeout: 10)          // ongoing → 詳情有「轉請款單」
        _ = btnC("預覽 PDF").waitForExistence(timeout: 6)
        tapIfPresent(btnC("轉請款單"))
        _ = stC("請款單").waitForExistence(timeout: 8)
        app.swipeUp()
        XCTAssertTrue(stC("玉山銀行").waitForExistence(timeout: 6),
                      "請款單付款方式應顯示模板設定的收款資訊")
        snap("42-Invoice-Payment")
    }
}
