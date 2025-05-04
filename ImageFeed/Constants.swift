import Foundation


enum Constants {
    
    // MARK: - OAuth
    
    static let accessKey = "_nfWaBfFXCEKdxk6YW-HHwN-fkmBfX4Q2rlMie_wuZc"
    static let secretKey = "BMYJnTs0bAApo4bu5S9cDh3qU8nSav1XdHunZtEgG2I"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let navBackButton = "nav_back_button"
    static var defaultBaseURL: URL? {
        return URL(string: "https://api.unsplash.com")
    }
}
