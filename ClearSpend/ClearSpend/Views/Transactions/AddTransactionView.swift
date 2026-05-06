import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var note = ""
    @State private var category = "Other"
    @State private var type: TransactionType = .expense
    @State private var isFronted = false
    @State private var isReimbursement = false
    @State private var date = Date()
    
    private let categories = ["Rent", "Groceries", "Dinner", "Lunch", "Breakfast", "Coffee", "Drinks", "Uber", "Utilities", "Subscription", "Gas", "Other"]
    private let onSave: (Decimal, String, String, TransactionType, Bool, Bool, Date) -> Void
    
    init(onSave: @escaping (Decimal, String, String, TransactionType, Bool, Bool, Date) -> Void) {
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.title2.bold())
                }
                
                Section("Details") {
                    TextField("Note", text: $note)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    Picker("Type", selection: $type) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(.segmented)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Split Options") {
                    Toggle("I fronted this for others", isOn: $isFronted)
                    if type == .income {
                        Toggle("This is a reimbursement", isOn: $isReimbursement)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let decimalAmount = Decimal(string: amount) ?? 0
                        guard decimalAmount > 0 else { return }
                        onSave(decimalAmount, note, category, type, isFronted, isReimbursement, date)
                        dismiss()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
}
