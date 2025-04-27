import Foundation

// MARK: - Class

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    // MARK: - Private Properties
    
    private let tokenKey = "oauth2_access_token"
    
    // MARK: - Public Properties
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    // MARK: - Public Methods
    
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
