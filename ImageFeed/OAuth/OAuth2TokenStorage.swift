import UIKit
import WebKit

final class OAuth2TokenStorage {
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
}
