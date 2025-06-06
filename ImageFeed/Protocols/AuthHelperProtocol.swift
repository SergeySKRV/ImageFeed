import Foundation

// MARK: - AuthHelperProtocol

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

// MARK: - AuthHelper

final class AuthHelper: AuthHelperProtocol {
    
    // MARK: - Properties
    
    let configuration: AuthConfiguration
    
    // MARK: - Init
    
    init(configuration: AuthConfiguration = .standart) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        guard url.isOAuthRedirectURL else { return nil }
        return url.queryParameterValue(forKey: "code")
    }
}
