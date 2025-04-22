import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Singleton
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: - Private Properties
    
    private let tokenKey = "OAuth2Token"
    
    // MARK: - Public Properties
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
    
    // MARK: - Public Methods
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
