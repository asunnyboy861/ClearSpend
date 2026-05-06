# ClearSpend - iOS Development Guide

## Executive Summary

ClearSpend is an iOS expense tracking and bill-splitting app that solves the fundamental problem of distorted budgets caused by Venmo reimbursements being treated as income. Unlike existing apps like Splitwise, which focus solely on splitting bills, ClearSpend uniquely distinguishes between money you spent on yourself (real spending) and money you fronted for others (temporary advances). The app provides a clear dashboard showing your true monthly expenditure after reimbursements, integrates Venmo deep links for seamless settlement, offers receipt OCR scanning for item-level splitting, and uses debt simplification algorithms to minimize settlement transactions.

**Target Audience**: US-based young adults (22-35) who use Venmo and share expenses with roommates, partners, friends, or travel groups.

**Key Differentiators**:
- Real spending calculator that separates fronted amounts from actual expenses
- Venmo transaction smart identification and deep link integration
- Receipt OCR with line-item splitting (not just lump-sum)
- Non-intrusive smart payment reminders
- iCloud sync via CloudKit for group sharing

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Splitwise | Market leader, 10M+ users, group management, debt simplification | Free tier limited to 3 expenses/day, no real spending tracking, Venmo deposits treated as income, Pro required for receipt scanning | Real spending engine, no daily limits on free tier, Venmo-aware classification, receipt OCR on free tier |
| Venmo Groups | Ubiquitous payment app, fast transfers, social feed | Cannot break receipts into line items, no budget tracking, treats reimbursements as income, no debt simplification | Item-level receipt splitting, real spending dashboard, debt simplification algorithm |
| Tricount | Free and unlimited, offline support, 17M users | No payment integration, no receipt scanning, no real spending analysis, limited analytics | Venmo deep link integration, receipt OCR, real spending calculator, budget tracking |
| Splid | Clean UI, offline-first, works without all users having app | No in-app payments, no receipt scanning, no budget tracking | All-in-one: split + track + budget + settle |
| Split (Bill Splitter) | AI receipt scanning, item assignment | No real spending tracking, no budget management, subscription required for full features | Real spending engine, budget management, free core features |

## Apple Design Guidelines Compliance

- **Hierarchy**: Dashboard shows real spending as primary metric, with total/fronted/reimbursed as secondary breakdown
- **Harmony**: Uses system fonts (SF Pro), native SwiftUI components, and standard navigation patterns
- **Consistency**: Tab-based navigation following iOS conventions; consistent color coding (green for income/reimbursement, red for expense)
- **Accessibility**: Dynamic Type support, VoiceOver labels on all interactive elements, minimum 44pt touch targets, 4.5:1 contrast ratios
- **Materials**: Uses system background materials and vibrancy for card overlays
- **Layout**: Adaptive layouts for iPhone and iPad with max-width constraints on iPad (720pt)
- **Navigation**: TabView with 5 tabs (Dashboard, Transactions, Split, Stats, Settings) following iOS Finance app patterns

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (camera picker only)
- **Data**: Core Data with NSPersistentCloudKitContainer for iCloud sync
- **Image Processing**: Vision Framework (VNRecognizeTextRequest) for receipt OCR
- **Networking**: URLSession for feedback submission
- **Payments**: StoreKit 2 for in-app purchases
- **Notifications**: UserNotifications framework for payment reminders
- **Deep Links**: URL schemes for Venmo integration
- **Charts**: Swift Charts framework for statistics
- **Minimum iOS**: 17.0

## Module Structure

```
ClearSpend/
├── ClearSpendApp.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── SpendingBreakdownCard.swift
│   │   └── RecentTransactionsCard.swift
│   ├── Transactions/
│   │   ├── TransactionListView.swift
│   │   ├── AddTransactionView.swift
│   │   └── TransactionRowView.swift
│   ├── Split/
│   │   ├── SplitView.swift
│   │   ├── ReceiptScanView.swift
│   │   ├── ItemAssignmentView.swift
│   │   └── SettlementView.swift
│   ├── Stats/
│   │   ├── StatsView.swift
│   │   └── BudgetView.swift
│   ├── Groups/
│   │   ├── GroupListView.swift
│   │   └── GroupDetailView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ContactSupportView.swift
│   │   └── PaywallView.swift
│   └── Components/
│       ├── AmountTextField.swift
│       ├── CategoryPicker.swift
│       └── MemberPicker.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── TransactionViewModel.swift
│   ├── SplitViewModel.swift
│   ├── StatsViewModel.swift
│   ├── GroupViewModel.swift
│   └── PurchaseManager.swift
├── Models/
│   └── DataModels.swift (Core Data entities extension)
├── Services/
│   ├── RealSpendCalculator.swift
│   ├── ReceiptScannerService.swift
│   ├── DebtSimplifier.swift
│   ├── ReimbursementEngine.swift
│   ├── VenmoDeeplinkService.swift
│   ├── NotificationService.swift
│   └── DataManager.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Formatter.swift
└── Assets.xcassets/
```

## Implementation Flow

1. Set up Core Data model with all entities (Book, Category, Transaction, Member, Budget, Account, SplitRecord, ReimbursementLink, ReceiptItem)
2. Create DataManager with iCloud sync toggle
3. Build Dashboard view with real spending breakdown
4. Implement RealSpendCalculator engine
5. Build Transaction list and add transaction flow
6. Implement ReimbursementEngine for Venmo classification
7. Build Split view with receipt OCR scanning
8. Implement ReceiptScannerService using Vision framework
9. Build item assignment and settlement views
10. Implement DebtSimplifier algorithm
11. Build Stats view with Swift Charts
12. Build Budget management view
13. Implement Group views with CloudKit sharing
14. Build Venmo deep link integration
15. Implement NotificationService for payment reminders
16. Build Settings with policy links, contact support, and IAP
17. Implement PurchaseManager with StoreKit 2
18. Build Paywall view
19. Configure capabilities and entitlements
20. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #007AFF (systemBlue) for actions and navigation
  - Success/Income: #34C759 (systemGreen) for reimbursements received
  - Expense: #FF3B30 (systemRed) for expenses
  - Fronted: #FF9500 (systemOrange) for fronted amounts
  - Pending: #8E8E93 (systemGray) for pending reimbursements
  - Background: System backgrounds (automatic light/dark mode)
- **Typography**: SF Pro system font, 34pt large titles, 17pt body, 14pt captions
- **Layout**:
  - Tab-based navigation with 5 tabs
  - Card-based dashboard with rounded corners (16pt radius)
  - Max width 720pt on iPad for content areas
  - 16pt horizontal padding, 12pt vertical spacing between cards
- **Animations**: Standard SwiftUI transitions, spring animations for card interactions, smooth number transitions for spending amounts

## Code Generation Rules

- Single responsibility: one feature per module
- MVVM pattern: View + ViewModel for each feature
- All Core Data attributes must be optional or have default values
- All Core Data relationships must have inverse relationships
- Use NSPersistentContainer first, switch to NSPersistentCloudKitContainer when CloudKit configured
- Never add comments in code unless asked
- Use native Apple frameworks first (Vision, Swift Charts, CloudKit)
- iPad layouts must use .frame(maxWidth: 720).frame(maxWidth: .infinity) for ScrollView content
- Never use .tabViewStyle(.sidebarAdaptable)
- All interactive elements must have 44pt minimum touch target

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.ClearSpend
2. Verify Deployment Target: iOS 17.0
3. Configure capabilities: iCloud, Push Notifications, Camera
4. Add Venmo URL scheme to Info.plist LSApplicationQueriesSchemes
5. Generate app icon using Wanxiang API
6. Build and test on iPhone XS Max simulator
7. Build and test on iPad Pro 13-inch (M4) simulator
8. Push to GitHub repository
9. Deploy policy pages to GitHub Pages
10. Create App Store Connect metadata
