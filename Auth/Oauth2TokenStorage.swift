import Foundation
import SwiftKeychainWrapper

final class Oauth2TokenStorage {
    
    // MARK: - Shared Instance
    
    static let shared = Oauth2TokenStorage()
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Properties
    
    var token: String? {
        get {
            guard let token = KeychainWrapper.standard.string(forKey: Constants.keychainOAuthTokenKeyName) else {
                AppLogger.info("No OAuth2 token found in keychain")
                return nil
            }
            return token
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: Constants.keychainOAuthTokenKeyName)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Constants.keychainOAuthTokenKeyName)
            }
        }
    }
}
