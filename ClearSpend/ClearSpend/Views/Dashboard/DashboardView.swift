import SwiftUI
import CoreData

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthSelector
                    
                    if let breakdown = viewModel.spendingBreakdown {
                        realSpendingCard(breakdown)
                        breakdownCards(breakdown)
                    } else {
                        emptyStateView
                    }
                    
                    recentTransactionsSection
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("ClearSpend")
        }
        .onAppear {
            viewModel.loadDashboard()
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: viewModel.previousMonth) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.selectedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.headline)
            Spacer()
            Button(action: viewModel.nextMonth) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private func realSpendingCard(_ breakdown: SpendingBreakdown) -> some View {
        VStack(spacing: 8) {
            Text("Your Real Spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(breakdown.realSpending.currencyString)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text("After reimbursements & fronted amounts")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .cardStyle()
    }
    
    private func breakdownCards(_ breakdown: SpendingBreakdown) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                breakdownItem(title: "Total Spent", amount: breakdown.totalSpent, color: .appExpense)
                breakdownItem(title: "Fronted", amount: breakdown.frontedForOthers, color: .appFronted)
            }
            HStack(spacing: 12) {
                breakdownItem(title: "Reimbursed", amount: breakdown.reimbursed, color: .appSuccess)
                breakdownItem(title: "Pending", amount: breakdown.pendingReimbursement, color: .appPending)
            }
        }
    }
    
    private func breakdownItem(title: String, amount: Decimal, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(amount.currencyString)
                .font(.title3.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)
            
            if viewModel.recentTransactions.isEmpty {
                Text("No transactions this month")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(viewModel.recentTransactions, id: \.objectID) { tx in
                    transactionRow(tx)
                }
            }
        }
        .cardStyle()
    }
    
    private func transactionRow(_ tx: TransactionEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.note ?? "Untitled")
                    .font(.subheadline)
                Text(tx.category ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text((tx.amount ?? 0).decimalValue.currencyString)
                    .font(.subheadline.bold())
                    .foregroundColor(tx.type == TransactionType.expense.rawValue ? .appExpense : .appSuccess)
                if tx.isFronted {
                    Text("Fronted")
                        .font(.caption2)
                        .foregroundColor(.appFronted)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.appFronted.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No spending data yet")
                .font(.headline)
            Text("Add transactions to see your real spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
        .cardStyle()
    }
}
