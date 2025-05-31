import Foundation

enum Constants {
    static let accessKey = "_nfWaBfFXCEKdxk6YW-HHwN-fkmBfX4Q2rlMie_wuZc"
    static let secretKey = "BMYJnTs0bAApo4bu5S9cDh3qU8nSav1XdHunZtEgG2I"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let oauthTokenURL = "https://unsplash.com/oauth/token"
    
    static let keychainOAuthTokenKeyName = "oauthToken"
}
