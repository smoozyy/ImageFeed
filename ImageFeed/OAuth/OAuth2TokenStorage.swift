import UIKit
import WebKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {
    }
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        set {
            guard let newValue else {
                KeychainWrapper.standard.removeObject(forKey: "token")
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: "token")
        }
    }
}
