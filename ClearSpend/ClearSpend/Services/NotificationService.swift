import Foundation
import UserNotifications

final class NotificationService {
    
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }
    
    func schedulePaymentReminder(to memberName: String, amount: Decimal, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "\(memberName) owes you \(amount.currencyString). Time for a friendly reminder?"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "reminder-\(memberName)-\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleRecurringReminder(to memberName: String, amount: Decimal, dayOfMonth: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Monthly Reminder"
        content.body = "Time to settle up with \(memberName) — \(amount.currencyString) pending."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.day = dayOfMonth
        dateComponents.hour = 10
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "recurring-\(memberName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
