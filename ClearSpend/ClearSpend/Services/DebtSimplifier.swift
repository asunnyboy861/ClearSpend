import Foundation

final class DebtSimplifier {
    
    func simplifyDebts(members: [(id: UUID, name: String)], expenses: [TransactionEntity]) -> [Settlement] {
        var balances: [UUID: Decimal] = [:]
        for member in members {
            balances[member.id] = 0
        }
        
        for expense in expenses {
            guard let payerId = expense.memberId else { continue }
            let amount = (expense.amount ?? 0).decimalValue
            balances[payerId] = (balances[payerId] ?? 0) + amount
            
            let splitCount = Decimal(members.count)
            let sharePerPerson = amount / splitCount
            for member in members {
                balances[member.id] = (balances[member.id] ?? 0) - sharePerPerson
            }
        }
        
        var creditors: [(UUID, String, Decimal)] = []
        var debtors: [(UUID, String, Decimal)] = []
        
        for member in members {
            let balance = balances[member.id] ?? 0
            if balance > 0 {
                creditors.append((member.id, member.name, balance))
            } else if balance < 0 {
                debtors.append((member.id, member.name, -balance))
            }
        }
        
        creditors.sort { $0.2 > $1.2 }
        debtors.sort { $0.2 > $1.2 }
        
        var settlements: [Settlement] = []
        var i = 0, j = 0
        
        while i < debtors.count && j < creditors.count {
            let amount = min(debtors[i].2, creditors[j].2)
            if amount > 0 {
                settlements.append(Settlement(
                    fromName: debtors[i].1,
                    toName: creditors[j].1,
                    amount: amount
                ))
            }
            debtors[i].2 -= amount
            creditors[j].2 -= amount
            if debtors[i].2 == 0 { i += 1 }
            if creditors[j].2 == 0 { j += 1 }
        }
        
        return settlements
    }
}
