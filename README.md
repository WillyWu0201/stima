# Stima（師傅的報價工具）

專為台灣裝潢師傅打造的 SwiftUI iOS App：**快速開逐項報價單、追工程與收款進度、管理客戶、產生 PDF、看營運統計**。

> 報得快、收得回，師傅的生意更穩。

---

## 功能

- **逐項報價單** — 從內建項目庫（拆除／水電／泥作／木作…）或自訂項目挑選，數量單價即時計稅、算總計
- **工程狀態追蹤** — 草稿 → 進行中 → 已完工 → 已收款
- **客戶簿** — 聯絡資料、案件數、累計已收款、一鍵撥打／導航／新報價
- **PDF 產生** — A4 整頁報價單，可自訂抬頭／Logo／印章／付款條件（PRO）
- **營運統計** — 年度已收款、待收款、進行中、每月長條圖、最大客戶、最常做的項目、單價趨勢
- **地圖選點** — MapKit 搜尋 + 目前位置反查地址
- **CSV 匯出** — 一鍵匯出所有報價單（UTF-8 + BOM，Excel 開中文不亂碼）
- **PRO 訂閱** — 無限報價單、自訂 PDF 模板、移除浮水印、請款單、iCloud 備份、進階統計
- **多語系** — 預設繁體中文，支援 zh-Hans / en / vi / id

## 技術

| 面向 | 使用 |
|---|---|
| UI | SwiftUI（`@Observable` 狀態、`TabView` + `NavigationStack`）|
| 持久化 | SwiftData（`Quote` / `QuoteItem` / `Client` / `CustomItem` / `PDFTemplate`）；設定存 `UserDefaults` |
| PDF | PDFKit（A4 595×842）|
| 地圖／定位 | MapKit + CoreLocation |
| 購買 | StoreKit / RevenueCat（未接 SDK 時走開發用 fallback）|
| 單元測試 | Swift Testing |
| UI 測試 | XCTest |

## 需求

- Xcode（iOS 26 SDK）
- 部署目標 **iOS 26.0**
- App 顯示名稱：**Stima**

## 建置與執行

用 Xcode 開啟 `stima.xcodeproj`，選 iPhone 模擬器，⌘R 執行。

CLI：

```bash
# 建置（模擬器）
xcodebuild -project stima.xcodeproj -scheme stima \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# 執行全部測試
xcodebuild test -project stima.xcodeproj -scheme stima \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 測試

- **單元測試**（`stimaTests/`，Swift Testing）— Model 金額計算、稅率、狀態、`TierGate` 配額、`YearStatsCalculator` 統計推導、`ShareMessage`、`PDFExporter`、CSV 匯出等純邏輯，邏輯層覆蓋率接近 100%。
- **UI 測試**（`stimaUITests/`，XCTest）— 走訪各畫面驗證流程與版面。

App 內建 UI 測試專用 launch arguments（見 `stimaApp.swift`）：

| 參數 | 作用 |
|---|---|
| `--uitest-reset` | 清掉 onboarding／PRO 等 UserDefaults 狀態 |
| `--uitest-inmemory` | SwiftData 改用 in-memory，每次啟動都乾淨 |
| `--uitest-seed` | 灌入 `PreviewData` 範例客戶／報價單（測需要資料的畫面）|
| `--uitest-onboarded` | 標記已看過 onboarding，直接進主畫面（跳過教學 coach mark）|

```bash
# 只跑單元測試
xcodebuild test -project stima.xcodeproj -scheme stima \
  -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:stimaTests

# UI 測試建議關閉平行化（避免 CoreSimulator 開一堆 clone 導致不穩）
xcodebuild test -project stima.xcodeproj -scheme stima \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:stimaUITests -parallel-testing-enabled NO
```

## 架構

3 個底部 tab，各自一個 `NavigationStack`：

```
TabView
├── 報價單 HomeScreen → DetailScreen → ClientDetailScreen / InvoiceScreen / PDFPreviewSheet
├── 統計   StatsScreen → ClientDetailScreen / ItemDetailScreen
└── 設定   SettingsScreen → ContactsScreen → ClientDetailScreen
                          → PDFTemplateScreen / PaywallScreen

新增報價（modal）：NewQuoteInfoScreen → NewQuoteItemsScreen → NewQuoteReviewScreen → ExportedScreen
首次啟動：SplashScreen → IntroScreen → TutorialCTAScreen
```

**PRO 功能閘門**集中在 [`stima/TierConfig.swift`](stima/TierConfig.swift)——所有額度與 gate 只在這裡調整，`TierConfig.requires(_:isPro:)` 為統一檢查點。

## 專案結構

```
stima/
├── Models/           SwiftData 模型（Quote, Client, CustomItem, PDFTemplate）
├── Components/        共用元件（按鈕、卡片、Money、狀態徽章、CSV 匯出…）
├── Screens/          各功能畫面（Home / Detail / Contacts / NewQuote / PDF / Stats / Settings / Paywall / Onboarding / LocationPicker）
├── DesignTokens.swift 色彩／字體／間距／圓角（Theme A 踏實版）
├── TierConfig.swift   免費／PRO 界線
├── PurchaseManager.swift  RevenueCat 訂閱管理
└── PreviewData.swift  #Preview 與 UI 測試 seed 用的範例資料
```

## 設計

設計主題 **Theme A（踏實版）**——暖奶油底 + 磚橘強調色。完整設計稿見 [`design_handoff_quote_app/`](design_handoff_quote_app/)（瀏覽器開 `index.html` 可互動檢視全部畫面）。
