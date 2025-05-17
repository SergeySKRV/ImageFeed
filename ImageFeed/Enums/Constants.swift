import Foundation

enum Constants {
    
    // MARK: - OAuth
    
    static let accessKey = "_nfWaBfFXCEKdxk6YW-HHwN-fkmBfX4Q2rlMie_wuZc"
    static let secretKey = "BMYJnTs0bAApo4bu5S9cDh3qU8nSav1XdHunZtEgG2I"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let navBackButton = "nav_back_button"
    static let oauthTokenURL = "https://unsplash.com/oauth/token"
    static let keychainOAuthTokenKeyName = "oauthToken"
    static var defaultBaseURL: URL? {
        return URL(string: "https://api.unsplash.com")
    }
}

enum AuthViewControllerConstants {
    static let loginButtonTitle: String = "Войти"
    static let errorAlertTitle: String = "Что-то пошло не так"
    static let errorAlertMessage: String = "Не удалось войти в систему"
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let redirectPath = "/oauth/authorize/native"
}
