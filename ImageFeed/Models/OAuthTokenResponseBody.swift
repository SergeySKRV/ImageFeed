import Foundation

// MARK: - Struct

struct OAuthTokenResponseBody: Decodable {
    
    // MARK: - Properties
    
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
