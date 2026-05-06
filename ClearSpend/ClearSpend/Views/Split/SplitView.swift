import SwiftUI

struct SplitView: View {
    @StateObject private var viewModel = SplitViewModel()
    @State private var showingScanner = false
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    membersSection
                    addExpenseSection
                    settlementsSection
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Split")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingScanner = true }) {
                        Image(systemName: "doc.text.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ReceiptScanView { receipt in
                    viewModel.scannedReceipt = receipt
                    if let firstItem = receipt.items.first {
                        viewModel.expenseDescription = firstItem.name
                        viewModel.expenseAmount = receipt.total
                    }
                }
            }
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Members")
                .font(.headline)
            
            HStack {
                TextField("Add member name", text: $viewModel.memberNameInput)
                    .textFieldStyle(.roundedBorder)
                Button(action: { viewModel.addMember(name: viewModel.memberNameInput) }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.memberNameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if !viewModel.members.isEmpty {
                ForEach(viewModel.members, id: \.id) { member in
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                        Text(member.name)
                            .font(.subheadline)
                        Spacer()
                        if let index = viewModel.members.firstIndex(where: { $0.id == member.id }) {
                            Button(action: { viewModel.removeMember(at: index) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .cardStyle()
    }
    
    private var addExpenseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Expense")
                .font(.headline)
            
            TextField("Description", text: $viewModel.expenseDescription)
                .textFieldStyle(.roundedBorder)
            
            TextField("Amount", value: $viewModel.expenseAmount, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            
            if let receipt = viewModel.scannedReceipt {
                receiptPreview(receipt)
            }
            
            Button(action: viewModel.addExpense) {
                Label("Add Expense", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.members.isEmpty || viewModel.expenseAmount <= 0)
        }
        .cardStyle()
    }
    
    private func receiptPreview(_ receipt: ScannedReceipt) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Scanned Receipt")
                .font(.caption)
                .foregroundColor(.secondary)
            if let merchant = receipt.merchantName {
                Text(merchant)
                    .font(.subheadline.bold())
            }
            ForEach(receipt.items) { item in
                HStack {
                    Text(item.name)
                        .font(.caption)
                    Spacer()
                    Text(item.amount.currencyString)
                        .font(.caption)
                }
            }
            HStack {
                Spacer()
                Text("Total: \(receipt.total.currencyString)")
                    .font(.caption.bold())
            }
        }
        .padding(8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var settlementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settlements")
                .font(.headline)
            
            if viewModel.settlements.isEmpty {
                Text("Add expenses to see settlements")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.settlements) { settlement in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(settlement.fromName) owes \(settlement.toName)")
                                .font(.subheadline)
                            Text(settlement.amount.currencyString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.openVenmoRequest(from: settlement.fromName, amount: settlement.amount)
                        }) {
                            Label("Request", systemImage: "dollarsign.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .cardStyle()
    }
}
