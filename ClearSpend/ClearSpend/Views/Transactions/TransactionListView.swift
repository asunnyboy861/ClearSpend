import SwiftUI
import CoreData

struct TransactionListView: View {
    @StateObject private var viewModel = TransactionViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthSelector
                    
                    if viewModel.groupedByDate.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(viewModel.groupedByDate, id: \.0) { date, transactions in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                ForEach(transactions, id: \.objectID) { tx in
                                    transactionRow(tx)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteTransaction(tx)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .searchable(text: $viewModel.searchText, prompt: "Search transactions")
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddTransactionView { amount, note, category, type, isFronted, isReimbursement, date in
                    viewModel.addTransaction(
                        amount: amount,
                        note: note,
                        category: category,
                        type: type,
                        isFronted: isFronted,
                        isReimbursement: isReimbursement,
                        date: date
                    )
                }
            }
            .onAppear {
                viewModel.loadTransactions()
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { viewModel.selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.selectedMonth) ?? viewModel.selectedMonth; viewModel.loadTransactions() }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.selectedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.headline)
            Spacer()
            Button(action: { viewModel.selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.selectedMonth) ?? viewModel.selectedMonth; viewModel.loadTransactions() }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private func transactionRow(_ tx: TransactionEntity) -> some View {
        HStack {
            Image(systemName: categoryIcon(tx.category ?? ""))
                .foregroundColor(categoryColor(tx.category ?? ""))
                .frame(width: 36, height: 36)
                .background(categoryColor(tx.category ?? "").opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.note ?? "Untitled")
                    .font(.subheadline)
                HStack {
                    Text(tx.category ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if tx.isFronted {
                        Text("Fronted")
                            .font(.caption2)
                            .foregroundColor(.appFronted)
                    }
                    if tx.isReimbursement {
                        Text("Reimbursed")
                            .font(.caption2)
                            .foregroundColor(.appSuccess)
                    }
                }
            }
            Spacer()
            Text((tx.amount ?? 0).decimalValue.currencyString)
                .font(.subheadline.bold())
                .foregroundColor(tx.type == TransactionType.expense.rawValue ? .appExpense : .appSuccess)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No transactions yet")
                .font(.headline)
            Text("Tap + to add your first transaction")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
    
    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "rent": return "house"
        case "groceries", "grocery": return "cart"
        case "dinner", "lunch", "breakfast": return "fork.knife"
        case "drinks", "coffee": return "cup.and.saucer"
        case "uber", "lyft", "transport": return "car"
        case "utilities": return "bolt"
        case "subscription": return "play.circle"
        case "split": return "arrow.triangle.2.circlepath"
        default: return "dollarsign.circle"
        }
    }
    
    private func categoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "rent": return .blue
        case "groceries", "grocery": return .green
        case "dinner", "lunch", "breakfast": return .orange
        case "drinks", "coffee": return .brown
        case "uber", "lyft", "transport": return .purple
        case "utilities": return .yellow
        case "subscription": return .red
        case "split": return .teal
        default: return .gray
        }
    }
}
