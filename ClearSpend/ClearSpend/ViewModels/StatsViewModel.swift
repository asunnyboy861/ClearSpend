import Foundation
import SwiftUI
import Charts
import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var categoryData: [(category: String, amount: Decimal)] = []
    @Published var monthlyTrend: [(month: String, amount: Decimal)] = []
    @Published var budgets: [BudgetEntity] = []
    @Published var selectedMonth = Date()
    
    private let dataManager = DataManager.shared
    private let calculator = RealSpendCalculator()
    
    func loadStats() {
        let transactions = dataManager.fetchTransactions(for: selectedMonth)
        let interval = selectedMonth.monthInterval
        let breakdown = calculator.monthlyCategoryBreakdown(transactions: transactions, in: interval)
        
        categoryData = breakdown.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
        
        loadMonthlyTrend()
        loadBudgets()
    }
    
    private func loadMonthlyTrend() {
        var trend: [(month: String, amount: Decimal)] = []
        let calendar = Calendar.current
        for i in (0..<6).reversed() {
            guard let date = calendar.date(byAdding: .month, value: -i, to: selectedMonth) else { continue }
            let transactions = dataManager.fetchTransactions(for: date)
            let interval = date.monthInterval
            let breakdown = calculator.calculateRealSpending(transactions: transactions, in: interval)
            let monthStr = date.formatted(.dateTime.month(.abbreviated))
            trend.append((month: monthStr, amount: breakdown.realSpending))
        }
        monthlyTrend = trend
    }
    
    private func loadBudgets() {
        budgets = dataManager.fetchBudgets(for: selectedMonth)
    }
    
    func addBudget(category: String, amount: Decimal) {
        _ = dataManager.createBudget(category: category, amount: amount, month: selectedMonth.startOfMonth)
        loadBudgets()
    }
    
    func spentForCategory(_ category: String) -> Decimal {
        categoryData.first { $0.category == category }?.amount ?? 0
    }
}
