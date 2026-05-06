import Foundation

final class RealSpendCalculator {
    
    func calculateRealSpending(transactions: [TransactionEntity], in month: DateInterval) -> SpendingBreakdown {
        var totalSpent: Decimal = 0
        var frontedForOthers: Decimal = 0
        var reimbursed: Decimal = 0
        var pendingReimbursement: Decimal = 0
        
        for tx in transactions {
            guard let txDate = tx.date, month.contains(txDate) else { continue }
            let amount = (tx.amount ?? 0).decimalValue
            
            if tx.type == TransactionType.expense.rawValue {
                totalSpent += amount
                if tx.isFronted {
                    frontedForOthers += amount / 2
                }
            } else if tx.type == TransactionType.income.rawValue {
                if tx.isReimbursement {
                    reimbursed += amount
                }
            }
            
            if tx.isFronted && !tx.isReimbursement {
                pendingReimbursement += amount / 2
            }
        }
        
        let realSpending = totalSpent - frontedForOthers - reimbursed
        
        return SpendingBreakdown(
            totalSpent: totalSpent,
            frontedForOthers: frontedForOthers,
            reimbursed: reimbursed,
            realSpending: realSpending,
            pendingReimbursement: pendingReimbursement
        )
    }
    
    func monthlyCategoryBreakdown(transactions: [TransactionEntity], in month: DateInterval) -> [String: Decimal] {
        var categories: [String: Decimal] = [:]
        for tx in transactions {
            guard let txDate = tx.date, month.contains(txDate) else { continue }
            if tx.type == TransactionType.expense.rawValue {
                let cat = tx.category ?? "Other"
                categories[cat, default: 0] += (tx.amount ?? 0).decimalValue
            }
        }
        return categories
    }
}
