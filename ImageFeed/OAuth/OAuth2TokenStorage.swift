import UIKit
import WebKit

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {
    }
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }
    
}
