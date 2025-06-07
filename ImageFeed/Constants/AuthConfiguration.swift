import Foundation

// MARK: - AuthConfiguration

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let keychainTokenKey: String
    
    init(accessKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         defaultBaseURL: URL,
         authURLString: String,
         keychainTokenKey: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
        self.keychainTokenKey = keychainTokenKey
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString,
            keychainTokenKey: Constants.keychainOAuthTokenKeyName)
    }
}
