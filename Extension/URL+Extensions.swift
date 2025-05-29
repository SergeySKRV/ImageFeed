import Foundation

extension URL {
    func queryParameterValue(forKey key: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        return components.queryItems?.first{ $0.name == key }?.value
    }
    
    var isRedirectURLForOAuth: Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return false
        }
        return components.path == WebViewViewControllerConstants.redirectPath
    }
}
