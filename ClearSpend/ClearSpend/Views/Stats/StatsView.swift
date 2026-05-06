import SwiftUI
import Charts
import CoreData

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var showingAddBudget = false
    @State private var newBudgetCategory = ""
    @State private var newBudgetAmount = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    monthSelector
                    
                    spendingTrendChart
                    categoryBreakdownSection
                    budgetSection
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Add Budget", isPresented: $showingAddBudget) {
                TextField("Category", text: $newBudgetCategory)
                TextField("Amount", text: $newBudgetAmount)
                    .keyboardType(.decimalPad)
                Button("Add") {
                    let amount = Decimal(string: newBudgetAmount) ?? 0
                    if amount > 0 && !newBudgetCategory.isEmpty {
                        viewModel.addBudget(category: newBudgetCategory, amount: amount)
                    }
                    newBudgetCategory = ""
                    newBudgetAmount = ""
                }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                viewModel.loadStats()
            }
        }
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { viewModel.selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.selectedMonth) ?? viewModel.selectedMonth; viewModel.loadStats() }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(viewModel.selectedMonth.formatted(.dateTime.year().month(.wide)))
                .font(.headline)
            Spacer()
            Button(action: { viewModel.selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.selectedMonth) ?? viewModel.selectedMonth; viewModel.loadStats() }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
    
    private var spendingTrendChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending Trend")
                .font(.headline)
            
            if viewModel.monthlyTrend.isEmpty {
                Text("No data yet")
                    .foregroundColor(.secondary)
            } else {
                Chart(viewModel.monthlyTrend, id: \.month) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", NSDecimalNumber(decimal: item.amount).doubleValue)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 200)
                .chartYAxisLabel("USD")
            }
        }
        .cardStyle()
    }
    
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category Breakdown")
                .font(.headline)
            
            if viewModel.categoryData.isEmpty {
                Text("No expenses this month")
                    .foregroundColor(.secondary)
            } else {
                Chart(viewModel.categoryData, id: \.category) { item in
                    SectorMark(
                        angle: .value("Amount", NSDecimalNumber(decimal: item.amount).doubleValue),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(categoryColor(item.category).gradient)
                }
                .frame(height: 200)
                
                ForEach(viewModel.categoryData, id: \.category) { item in
                    HStack {
                        Circle()
                            .fill(categoryColor(item.category))
                            .frame(width: 10, height: 10)
                        Text(item.category)
                            .font(.subheadline)
                        Spacer()
                        Text(item.amount.currencyString)
                            .font(.subheadline.bold())
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Budgets")
                .font(.headline)
            
            if viewModel.budgets.isEmpty {
                Text("No budgets set. Tap + to add one.")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.budgets, id: \.objectID) { budget in
                    let spent = viewModel.spentForCategory(budget.category ?? "")
                    let budgetAmount = (budget.amount ?? 0).decimalValue
                    let progress = budgetAmount > 0 ? NSDecimalNumber(decimal: min(spent / budgetAmount, 1)).doubleValue : 0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(budget.category ?? "")
                                .font(.subheadline)
                            Spacer()
                            Text("\(spent.currencyString) / \(budgetAmount.currencyString)")
                                .font(.caption)
                                .foregroundColor(spent > budgetAmount ? .red : .secondary)
                        }
                        ProgressView(value: progress)
                            .tint(spent > budgetAmount ? .red : .blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .cardStyle()
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
