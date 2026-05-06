import Foundation
import SwiftUI
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var spendingBreakdown: SpendingBreakdown?
    @Published var recentTransactions: [TransactionEntity] = []
    @Published var selectedMonth = Date()
    @Published var categoryBreakdown: [String: Decimal] = [:]
    
    private let dataManager = DataManager.shared
    private let calculator = RealSpendCalculator()
    
    func loadDashboard() {
        let transactions = dataManager.fetchTransactions(for: selectedMonth)
        let interval = selectedMonth.monthInterval
        spendingBreakdown = calculator.calculateRealSpending(transactions: transactions, in: interval)
        categoryBreakdown = calculator.monthlyCategoryBreakdown(transactions: transactions, in: interval)
        recentTransactions = Array(transactions.prefix(5))
    }
    
    func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
        loadDashboard()
    }
    
    func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
        loadDashboard()
    }
}
