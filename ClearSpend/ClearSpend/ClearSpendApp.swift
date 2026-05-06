import SwiftUI

@main
struct ClearSpendApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(purchaseManager)
        }
    }
}
