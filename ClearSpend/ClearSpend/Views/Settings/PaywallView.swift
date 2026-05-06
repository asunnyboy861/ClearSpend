import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                featuresSection
                pricingSection
                restoreButton
                termsText
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(.yellow)
            Text("ClearSpend Premium")
                .font(.title.bold())
            Text("Unlock the full power of smart expense tracking")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(icon: "doc.text.viewfinder", title: "Receipt OCR Scanning", subtitle: "Scan and split line items")
            featureRow(icon: "chart.pie.fill", title: "Advanced Statistics", subtitle: "Charts, trends, and insights")
            featureRow(icon: "bell.fill", title: "Smart Reminders", subtitle: "Non-intrusive payment nudges")
            featureRow(icon: "arrow.triangle.2.circlepath", title: "Debt Simplification", subtitle: "Minimize settlement transactions")
            featureRow(icon: "icloud.fill", title: "iCloud Sync", subtitle: "Sync across all your devices")
            featureRow(icon: "square.and.arrow.up.fill", title: "Data Export", subtitle: "CSV and JSON export")
        }
        .cardStyle()
    }
    
    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            ForEach(purchaseManager.products, id: \.id) { product in
                Button(action: { purchase(product) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.displayName)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            Text(product.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(product.displayPrice)
                            .font(.title3.bold())
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    private var restoreButton: some View {
        Button("Restore Purchases") {
            Task {
                await purchaseManager.restorePurchases()
            }
        }
        .foregroundColor(.blue)
    }
    
    private var termsText: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
            .font(.caption2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private func purchase(_ product: Product) {
        Task {
            _ = await purchaseManager.purchase(product)
        }
    }
}
