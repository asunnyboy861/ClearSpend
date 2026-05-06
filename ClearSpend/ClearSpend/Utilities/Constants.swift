import Foundation

enum Constants {
    static let bundlePrefix = "com.zzoutuo.ClearSpend"
    
    enum IAP {
        static let monthlyProductId = "com.zzoutuo.ClearSpend.monthly"
        static let yearlyProductId = "com.zzoutuo.ClearSpend.yearly"
        static let lifetimeProductId = "com.zzoutuo.ClearSpend.lifetime"
    }
    
    enum Limits {
        static let freeTransactionLimit = 50
        static let freeGroupLimit = 2
    }
    
    enum URLs {
        static let supportURL = "https://asunnyboy861.github.io/ClearSpend/support.html"
        static let privacyURL = "https://asunnyboy861.github.io/ClearSpend/privacy.html"
        static let termsURL = "https://asunnyboy861.github.io/ClearSpend/terms.html"
        static let feedbackBackendURL = "https://feedback-board.iocompile67692.workers.dev"
    }
    
    enum Venmo {
        static let scheme = "venmo://"
    }
    
    static let contactEmail = "iocompile67692@gmail.com"
}
