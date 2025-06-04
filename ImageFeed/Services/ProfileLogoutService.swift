import Foundation
import WebKit

// MARK: - ProfileLogoutService

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    
    // MARK: - Shared Instance
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Dependencies
    
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let imageListService = ImageListService.shared
    private let oauthTokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Public Methods
    
    func logout() {
        cleanCookies()
        oauthTokenStorage.token = nil
        profileImageService.logout()
        profileService.logout()
        imageListService.logout()
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        
        let dataStore = WKWebsiteDataStore.default()
        let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        dataStore.fetchDataRecords(ofTypes: allTypes) { records in
            records.forEach {
                dataStore.removeData(ofTypes: $0.dataTypes, for: [$0], completionHandler: {})
            }
        }
    }
}
