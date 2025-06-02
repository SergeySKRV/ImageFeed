import Foundation

extension URL {
    func queryParameterValue(forKey key: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        return components.queryItems?.first(where: { $0.name == key })?.value
    }
    
    var isOAuthRedirectURL: Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return false
        }
        return components.path == Constants.redirectPath
    }
}
