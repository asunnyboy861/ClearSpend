import Foundation
import CoreData
import Combine

final class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var useCloudKit: Bool = false {
        didSet {
            UserDefaults.standard.set(useCloudKit, forKey: "useCloudKit")
        }
    }
    
    @Published var isPremium: Bool = false
    @Published var transactionCount: Int = 0
    @Published var groupCount: Int = 0
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ClearSpend")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        self.useCloudKit = UserDefaults.standard.bool(forKey: "useCloudKit")
    }
    
    var isFreeTransactionLimitReached: Bool {
        !isPremium && transactionCount >= Constants.Limits.freeTransactionLimit
    }
    
    var isFreeGroupLimitReached: Bool {
        !isPremium && groupCount >= Constants.Limits.freeGroupLimit
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func createTransaction(amount: Decimal, note: String, category: String, type: TransactionType, isFronted: Bool, isReimbursement: Bool, date: Date, memberId: UUID?) -> TransactionEntity {
        let tx = TransactionEntity(context: context)
        tx.id = UUID()
        tx.amount = NSDecimalNumber(decimal: amount)
        tx.note = note
        tx.category = category
        tx.type = type.rawValue
        tx.isFronted = isFronted
        tx.isReimbursement = isReimbursement
        tx.date = date
        tx.memberId = memberId
        tx.createdAt = Date()
        transactionCount += 1
        save()
        return tx
    }
    
    func fetchTransactions(for month: Date) -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        let interval = month.monthInterval
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", interval.start as NSDate, interval.end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchAllTransactions() -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        context.delete(transaction)
        transactionCount = max(0, transactionCount - 1)
        save()
    }
    
    func createGroup(name: String, members: [String]) -> GroupEntity {
        let group = GroupEntity(context: context)
        group.id = UUID()
        group.name = name
        group.createdAt = Date()
        for memberName in members {
            let member = MemberEntity(context: context)
            member.id = UUID()
            member.name = memberName
            member.group = group
        }
        groupCount += 1
        save()
        return group
    }
    
    func fetchGroups() -> [GroupEntity] {
        let request: NSFetchRequest<GroupEntity> = GroupEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    func createBudget(category: String, amount: Decimal, month: Date) -> BudgetEntity {
        let budget = BudgetEntity(context: context)
        budget.id = UUID()
        budget.category = category
        budget.amount = NSDecimalNumber(decimal: amount)
        budget.month = month
        save()
        return budget
    }
    
    func fetchBudgets(for month: Date) -> [BudgetEntity] {
        let request: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "month >= %@ AND month <= %@", month.startOfMonth as NSDate, month.endOfMonth as NSDate)
        return (try? context.fetch(request)) ?? []
    }
}
