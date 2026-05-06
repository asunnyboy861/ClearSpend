import Foundation

final class ReimbursementEngine {
    
    private let keywords = [
        "rent", "utilities", "electric", "water", "internet", "wifi",
        "groceries", "grocery", "uber", "lyft", "dinner", "lunch",
        "breakfast", "coffee", "drinks", "netflix", "spotify",
        "subscription", "gas", "parking", "ticket", "split", "share",
        "half", "portion", "owe", "owed", "payback", "reimburse",
        "venmo", "zelle", "cashapp"
    ]
    
    func classifyTransaction(_ venmoTx: VenmoTransaction) -> TransactionClassification {
        switch venmoTx.type {
        case .paymentReceived:
            if isReimbursementKeyword(venmoTx.note) {
                return .reimbursement(relatedExpenseKeyword: extractKeyword(venmoTx.note))
            }
            return .personalIncome
            
        case .paymentSent:
            return .personalExpense
            
        case .chargeSent:
            return .frontedExpense
            
        case .chargeReceived:
            return .personalExpense
        }
    }
    
    private func isReimbursementKeyword(_ note: String) -> Bool {
        let lower = note.lowercased()
        return keywords.contains { lower.contains($0) }
    }
    
    private func extractKeyword(_ note: String) -> String? {
        let lower = note.lowercased()
        return keywords.first { lower.contains($0) }
    }
}
