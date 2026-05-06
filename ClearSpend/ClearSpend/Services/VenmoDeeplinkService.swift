import UIKit

final class VenmoDeeplinkService {
    
    private let venmoScheme = "venmo://"
    
    enum VenmoAction {
        case requestPayment(recipient: String, amount: Decimal, note: String)
        case payUser(recipient: String, amount: Decimal, note: String)
    }
    
    func canOpenVenmo() -> Bool {
        guard let url = URL(string: venmoScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func createVenmoURL(_ action: VenmoAction) -> URL? {
        switch action {
        case .requestPayment(let recipient, let amount, let note):
            var components = URLComponents(string: "venmo://paycharge")
            components?.queryItems = [
                URLQueryItem(name: "txn", value: "charge"),
                URLQueryItem(name: "recipients", value: recipient),
                URLQueryItem(name: "amount", value: String(describing: amount)),
                URLQueryItem(name: "note", value: note)
            ]
            return components?.url
            
        case .payUser(let recipient, let amount, let note):
            var components = URLComponents(string: "venmo://paycharge")
            components?.queryItems = [
                URLQueryItem(name: "txn", value: "pay"),
                URLQueryItem(name: "recipients", value: recipient),
                URLQueryItem(name: "amount", value: String(describing: amount)),
                URLQueryItem(name: "note", value: note)
            ]
            return components?.url
        }
    }
    
    func openVenmo(_ action: VenmoAction) async throws -> Bool {
        guard canOpenVenmo() else {
            throw VenmoError.venmoNotInstalled
        }
        guard let url = createVenmoURL(action) else {
            throw VenmoError.invalidURL
        }
        return await UIApplication.shared.open(url)
    }
    
    enum VenmoError: Error {
        case invalidURL
        case venmoNotInstalled
    }
}
