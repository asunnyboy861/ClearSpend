import Foundation
import SwiftUI
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionEntity] = []
    @Published var selectedMonth = Date()
    @Published var searchText = ""
    @Published var showingAddSheet = false
    
    private let dataManager = DataManager.shared
    
    var filteredTransactions: [TransactionEntity] {
        if searchText.isEmpty {
            return transactions
        }
        return transactions.filter { tx in
            (tx.note?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (tx.category?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var groupedByDate: [(String, [TransactionEntity])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            guard let date = tx.date else { return "Unknown" }
            return Formatter.date.string(from: date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    func loadTransactions() {
        transactions = dataManager.fetchTransactions(for: selectedMonth)
    }
    
    func addTransaction(amount: Decimal, note: String, category: String, type: TransactionType, isFronted: Bool, isReimbursement: Bool, date: Date) {
        if dataManager.isFreeTransactionLimitReached {
            return
        }
        _ = dataManager.createTransaction(
            amount: amount,
            note: note,
            category: category,
            type: type,
            isFronted: isFronted,
            isReimbursement: isReimbursement,
            date: date,
            memberId: nil
        )
        loadTransactions()
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        dataManager.deleteTransaction(transaction)
        loadTransactions()
    }
}
