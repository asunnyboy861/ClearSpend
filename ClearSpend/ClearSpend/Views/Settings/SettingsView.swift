import SwiftUI

struct SettingsView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @AppStorage("useCloudKit") private var useCloudKit = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Text("Premium Status")
                        Spacer()
                        Text(purchaseManager.isPremium ? "Active" : "Free")
                            .foregroundColor(purchaseManager.isPremium ? .green : .secondary)
                    }
                    if !purchaseManager.isPremium {
                        NavigationLink(destination: PaywallView()) {
                            Text("Upgrade to Premium")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Sync") {
                    Toggle("iCloud Sync", isOn: $useCloudKit)
                    Text("Sync data across all your devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notifications") {
                    Button(action: requestNotificationPermission) {
                        Text("Enable Payment Reminders")
                    }
                }
                
                Section("Legal") {
                    Link("Support", destination: URL(string: Constants.URLs.supportURL)!)
                    Link("Privacy Policy", destination: URL(string: Constants.URLs.privacyURL)!)
                    Link("Terms of Use", destination: URL(string: Constants.URLs.termsURL)!)
                }
                
                Section("Feedback") {
                    NavigationLink(destination: ContactSupportView()) {
                        Text("Contact Support")
                    }
                }
                
                Section("Data") {
                    Button(action: exportData) {
                        Text("Export Data (CSV)")
                    }
                }
                
                if purchaseManager.isPremium {
                    Section("Subscription") {
                        Button("Restore Purchases") {
                            Task {
                                await purchaseManager.restorePurchases()
                            }
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }
    
    private func exportData() {
        let transactions = DataManager.shared.fetchAllTransactions()
        var csv = "Date,Type,Category,Note,Amount,Fronted,Reimbursement\n"
        for tx in transactions {
            let date = tx.date.map { Formatter.dateShort.string(from: $0) } ?? ""
            let note = (tx.note ?? "").replacingOccurrences(of: ",", with: ";")
            let amount = (tx.amount ?? 0).decimalValue
            csv += "\(date),\(tx.type ?? ""),\(tx.category ?? ""),\(note),\(NSDecimalNumber(decimal: amount).doubleValue),\(tx.isFronted),\(tx.isReimbursement)\n"
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ClearSpend_Export.csv")
        try? csv.data(using: .utf8)?.write(to: tempURL)
        
        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
