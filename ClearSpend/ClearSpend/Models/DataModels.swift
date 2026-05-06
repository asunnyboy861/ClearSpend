import Foundation
import CoreData

enum TransactionType: String, Codable {
    case expense
    case income
}

enum SplitType: String, Codable {
    case equal
    case percentage
    case shares
    case exact
}

struct SpendingBreakdown {
    let totalSpent: Decimal
    let frontedForOthers: Decimal
    let reimbursed: Decimal
    let realSpending: Decimal
    let pendingReimbursement: Decimal
}

struct Settlement: Identifiable {
    let id = UUID()
    let fromName: String
    let toName: String
    let amount: Decimal
}

struct ScannedReceipt {
    var items: [ReceiptLineItem]
    var subtotal: Decimal
    var tax: Decimal
    var tip: Decimal
    var total: Decimal
    var merchantName: String?
    var date: Date?
}

struct ReceiptLineItem: Identifiable {
    let id = UUID()
    var name: String
    var amount: Decimal
    var assignedToMemberId: UUID?
}

struct VenmoTransaction {
    let id: String
    let type: VenmoTransactionType
    let amount: Decimal
    let note: String
    let counterparty: String
    let date: Date
}

enum VenmoTransactionType {
    case paymentSent
    case paymentReceived
    case chargeSent
    case chargeReceived
}

enum TransactionClassification {
    case reimbursement(relatedExpenseKeyword: String?)
    case personalIncome
    case personalExpense
    case frontedExpense
}

struct FeedbackRequest: Codable {
    let topic: String?
    let name: String?
    let email: String
    let message: String
}
