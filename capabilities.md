# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:

- **iCloud/CloudKit**: Guide mentions "共享账本" (shared ledger), "CloudKit CKShare+iCloud同步", group sharing with multiple members
- **Camera/Photo Library**: Guide mentions "收据OCR扫描" (receipt OCR scanning), "CameraPickerView" (camera picker)
- **Push Notifications**: Guide mentions "智能催款提醒" (smart payment reminders), "NotificationService"
- **Venmo Deep Link**: Guide mentions "Venmo深度链接集成", URL scheme `venmo://`

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| iCloud (CloudKit) | ✅ Configured | Xcode Signing & Capabilities |
| Push Notifications | ✅ Configured | Xcode Signing & Capabilities |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Camera Usage Description | ⏳ Pending | Add NSCameraUsageDescription to Info.plist with "ClearSpend needs camera access to scan receipts" |
| Photo Library Usage Description | ⏳ Pending | Add NSPhotoLibraryUsageDescription to Info.plist with "ClearSpend needs photo access to import receipts" |
| Venmo URL Scheme | ⏳ Pending | Add "venmo" to LSApplicationQueriesSchemes in Info.plist |

## No Configuration Needed
- HealthKit: Not required (no health data)
- Location Services: Not required
- Apple Watch: Not required
- Siri: Not required
- Background Modes: Not required (local notifications only)
- Sign in with Apple: Not required
- In-App Purchase: Required but configured via StoreKit 2 in code

## Verification
- Build succeeded after configuration: ✅
- All entitlements correct: ✅
