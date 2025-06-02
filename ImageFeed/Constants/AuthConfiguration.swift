import Foundation

enum Constants {
    static let accessKey = "_nfWaBfFXCEKdxk6YW-HHwN-fkmBfX4Q2rlMie_wuZc"
    static let secretKey = "BMYJnTs0bAApo4bu5S9cDh3qU8nSav1XdHunZtEgG2I"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let oauthTokenURL = "https://unsplash.com/oauth/token"
    static let redirectPath = "/oauth/authorize/native"
    static let keychainOAuthTokenKeyName = "oauthToken"
    
    
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let keychainTokenKey: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String, keychainTokenKey: String) {
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
