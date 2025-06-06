import Foundation

// MARK: - URL Extension

extension URL {
    
    // MARK: - Query Parameter Extraction
    
    func queryParameterValue(forKey key: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == key })?.value
    }
    
    // MARK: - OAuth Redirect Check
    
    var isOAuthRedirectURL: Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return false
        }
        return components.path == Constants.redirectPath
    }
}
