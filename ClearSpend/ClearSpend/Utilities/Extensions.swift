import Foundation
import SwiftUI

extension Color {
    static let appPrimary = Color.blue
    static let appSuccess = Color.green
    static let appExpense = Color.red
    static let appFronted = Color.orange
    static let appPending = Color.gray
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
    }
    
    var monthInterval: DateInterval {
        DateInterval(start: startOfMonth, end: endOfMonth)
    }
    
    var formattedShort: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}

extension Decimal {
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }
}
