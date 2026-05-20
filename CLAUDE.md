# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**師傅號** — a SwiftUI iOS app for Taiwanese home-renovation contractors (裝潢師傅) to build itemized quotes, track job status, manage clients, generate PDFs, and view business statistics.

Design reference: `design_handoff_quote_app/` — open `index.html` in a browser to view all 21 screens interactively. `README.md` inside that folder is the authoritative spec.

**Active design theme: Theme A (踏實版)** — warm cream palette with brick-orange accent. See Design Tokens section below.

## Build & Run

Open `stima.xcodeproj` in Xcode. Target: iPhone (iOS 17+). Build shortcut: ⌘B. Run on simulator: ⌘R.

```bash
# CLI build (simulator)
xcodebuild -project stima.xcodeproj -scheme stima -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -project stima.xcodeproj -scheme stima -destination 'platform=iOS Simulator,name=iPhone 16'
```

SwiftLint runs as a build phase (once configured). To lint manually:
```bash
swiftlint lint --config .swiftlint.yml
```

## Architecture

### Navigation
`TabView` with 3 tabs at root: **報價單 (Home)** / **統計 (Stats)** / **設定 (Settings)**.

Each tab is a `NavigationStack`. Drill-in screens push onto the stack. Sheet presentations (map picker, item picker, new client, PDF preview) are modal overlays.

Screen inventory:
```
TabView
├── HomeScreen → DetailScreen → ClientDetailScreen
│                             → InvoiceScreen
├── StatsScreen → ClientDetailScreen
│              → ItemDetailScreen
└── SettingsScreen → ContactsScreen → ClientDetailScreen
                  → PDFTemplateScreen
                  → PaywallScreen

New quote flow (presented modally from Home):
  NewQuoteInfoScreen → NewQuoteItemsScreen → NewQuoteReviewScreen → ExportedScreen

Onboarding (first launch only):
  SplashScreen → IntroScreen → TutorialCTAScreen → (new quote flow)
```

Sheets (iOS page-sheet style):
- `LocationPickerSheet` — address / map autocomplete
- `ItemPickerSheet` — library item picker (preferred pattern per spec: 05c/05d)
- `NewClientSheet` — add contact
- `PDFPreviewSheet` — A4 paper preview

### Data & Persistence
SwiftData is used for local persistence. Core models:

| Model | Key fields |
|-------|-----------|
| `Quote` | id, client, location, date, total, itemList, folder, status (draft/ongoing/done/paid), dueDate |
| `QuoteItem` | name, unit, qty, price |
| `Client` | id, name, phone, email, address, notes, lastContact |
| `CustomItem` | name, unit, price, category |
| `PDFTemplate` | businessName, slogan, phone, email, address, paymentTerms, validDays, signatureLine, brandColor, fontStyle, logoData, stampData |

App-level settings (stored in `UserDefaults`): `masterName` (報價單抬頭), `taxRate`, `currency`, `language`, `isPro`, `hasSeenOnboarding`.

Stats are computed in-memory from `Quote` records — no separate stats model.

### State Management
Use `@Observable` view models per feature group (e.g. `QuoteStore`, `ClientStore`, `SettingsStore`) injected via `.environment`. Avoid threading `@State` deep through the view tree.

## Design Tokens — Theme A (踏實版)

### Colors — Light Mode
```swift
// Background
bg          = #F5F2EC  // warm cream paper
bgSoft      = #EFEAE0
surface     = #FFFFFF
surfaceAlt  = #FAF7F1

// Text
ink         = #1A1A1A
inkMid      = #3D3833
inkSoft     = #6B6660
inkFaint    = #9B8E7A

// Borders
border      = #E5E0D5
borderStrong= #C9BFB0

// Semantic
accent      = #C9522A  // brick orange — primary CTA, 進行中 status
accent2     = #E89B5C  // peach — large money displays
positive    = #5C8A6B  // moss green — 已完工 status
cool        = #3E6B9B  // slate blue — 已收款 status
warn        = #A37B2E

// Header/hero cards — ALWAYS dark, never inverts in dark mode
accentSurface     = #1A1A1A
accentSurfaceInk  = #F5F2EC
```

### Colors — Dark Mode overrides
```swift
bg = #17140F | bgSoft = #1F1B16 | surface = #26221C | surfaceAlt = #2E2923
ink = #F2EDE3 | inkMid = #CFC7BB | inkSoft = #9A9085 | inkFaint = #6E6459
border = #3A332C | borderStrong = #52473A
accent = #E89B5C | accent2 = #C9522A  // swapped in dark
positive = #7FB890 | cool = #7FA8D6
accentSurface = #0E0B07  // darker than bg, never inverts
```

### Typography
目前使用系統字體（iOS 在中文環境下自動採用 PingFang TC）。若之後要切換到設計稿指定的 Noto Sans TC / IBM Plex Mono，把字體檔加進 Xcode 並改 `AppFont.sans` / `AppFont.mono` 即可。

```swift
AppFont.sans(size, weight: .regular)   // body, UI（系統字體）
AppFont.mono(size, weight: .regular)   // 金額、日期、ID（系統 monospaced）
```

Type scale (points): 28–32 hero / 22–24 nav title / 20 money totals / 17 form input / 15–16 body / 13–14 sublabels / 11–12 mono hints.  
Support user font-scale setting (85%–125%) via `AppSettings.fontScale`.

### Spacing & Radii
```
Horizontal screen padding:  20–22pt
Card padding:               16pt
Gap between cards:          12pt
BottomCTA padding:          14pt top / 22pt sides / 36pt bottom (clears home indicator)

radius    = 14pt  (cards, inputs, secondary buttons)
radiusBig = 22pt  (sheets, hero surfaces)
Pills     = 999pt
Sheets top corners = 12pt
```

### Status Badges
| Status | Color |
|--------|-------|
| 進行中 | accent `#C9522A` (light) / `#E89B5C` (dark) |
| 已完工 | positive green |
| 已收款 | cool blue |
| 草稿 | inkFaint warm gray |

Pill style: filled tint background at 10% opacity + bold colored text + small dot.

### Active Tab / Pill
Active fill = `accent` (brick orange) in **both** light and dark modes. Never use adaptive ink color — it inverts and creates a jarring slab in dark mode.

### Sheet Presentation
```
Height:            calc(100% - 22pt) — 22pt peek strip
Parent transform:  scale(0.93) from top center, corner-radius 14, opacity 0.85
Dim layer:         rgba(0,0,0,0.3) behind parent
Slide-up:          0.32s cubic-bezier(.2,.7,.3,1)
Drag handle:       38×5pt gray pill, top center
```

## PRO Feature Gating

All limits and gates are centralised in [`stima/TierConfig.swift`](stima/TierConfig.swift) — **change numbers there only**, never hardcode them in views.

Key constants:
- `TierConfig.freeMonthlyQuoteLimit` — max quotes/month on free tier (default 3)
- `TierConfig.ProFeature` enum — one case per gated capability
- `TierConfig.requires(_:isPro:)` — call this at every gate check
- `TierConfig.iapMonthlyID` / `iapYearlyID` — StoreKit product IDs
- `TierConfig.watermark*` — text, angle, opacity for the PDF overlay

When a locked action is tapped, navigate to `PaywallScreen`. Never silently skip — show the upsell.

## SwiftUI Conventions

- **`@Observable`** for view models (iOS 17+). Avoid `ObservableObject`/`@Published`.
- **SwiftData** (`@Model`) for Quote, Client, CustomItem, PDFTemplate. Settings in `UserDefaults` via `@AppStorage`.
- **Numeric display**: always use `.monospacedDigit()` modifier on money/date/qty `Text` views so columns align.
- **Keyboard types**: `.decimalPad` for price inputs, `.numberPad` for qty, `.phonePad` for phone fields.
- **Date input**: use `DatePicker` (native), not a text field.
- **Maps / Location**: `MapKit` for the location picker sheet. Reverse-geocode the dropped pin with `CLGeocoder`.
- **PDF generation**: `PDFKit` matching the spec in screen 14. Structure mirrors the HTML preview 1:1.
- **Share**: `ShareLink` / `UIActivityViewController`. Never design a custom share sheet.
- **Native phone/navigation**: `tel:` URL scheme for calls; `MKMapItem` + `openInMaps` for navigation.
- **Tap targets**: minimum 44×44pt per iOS HIG.
- **Onboarding gate**: check `UserDefaults.bool("hasSeenOnboarding")` at launch.

## Localization

Default locale: **zh-Hant (Traditional Chinese)**. All UI strings should be wrapped in `String(localized:)` / `LocalizedStringKey` from the start, even before other locales are added. Supported locales per spec: zh-Hant, zh-Hans, en, vi, id.

Currency formatting uses `Intl`-equivalent Swift: `NumberFormatter` with `currencyCode` set from the user's currency setting (TWD / VND / IDR / USD / MYR / PHP).
