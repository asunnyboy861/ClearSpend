import Foundation
import SwiftUI
import Combine

@MainActor
final class SplitViewModel: ObservableObject {
    @Published var settlements: [Settlement] = []
    @Published var members: [(id: UUID, name: String)] = []
    @Published var memberNameInput = ""
    @Published var expenseDescription = ""
    @Published var expenseAmount: Decimal = 0
    @Published var splitType: SplitType = .equal
    @Published var scannedReceipt: ScannedReceipt?
    @Published var isScanning = false
    
    private let debtSimplifier = DebtSimplifier()
    private let dataManager = DataManager.shared
    
    func addMember(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if dataManager.isFreeGroupLimitReached && members.count >= Constants.Limits.freeGroupLimit {
            return
        }
        members.append((id: UUID(), name: name.trimmingCharacters(in: .whitespaces)))
        memberNameInput = ""
    }
    
    func removeMember(at index: Int) {
        guard index < members.count else { return }
        members.remove(at: index)
    }
    
    func addExpense() {
        guard !members.isEmpty, expenseAmount > 0 else { return }
        _ = dataManager.createTransaction(
            amount: expenseAmount,
            note: expenseDescription,
            category: "Split",
            type: .expense,
            isFronted: true,
            isReimbursement: false,
            date: Date(),
            memberId: members.first?.id
        )
        calculateSettlements()
        expenseDescription = ""
        expenseAmount = 0
    }
    
    func calculateSettlements() {
        let expenses = dataManager.fetchAllTransactions().filter { $0.isFronted }
        settlements = debtSimplifier.simplifyDebts(members: members, expenses: expenses)
    }
    
    func openVenmoRequest(from memberName: String, amount: Decimal) {
        let service = VenmoDeeplinkService()
        let action = VenmoDeeplinkService.VenmoAction.requestPayment(
            recipient: memberName,
            amount: amount,
            note: "ClearSpend settlement"
        )
        Task {
            _ = try? await service.openVenmo(action)
        }
    }
}
