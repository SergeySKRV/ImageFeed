import Foundation

// MARK: - Profile Model

struct Profile {
    let username: String
    let firstName: String
    let lastName: String?
    
    var fullName: String {
        "\(firstName) \(lastName ?? "")"
    }
    
    var loginName: String {
        "@\(username)"
    }
    
    let bio: String?
    
    init(from profileResponse: ProfileResponse) {
        username = profileResponse.username
        firstName = profileResponse.firstName
        lastName = profileResponse.lastName
        bio = profileResponse.bio
    }
}

// MARK: - Errors

enum ProfileServiceError: Error {
    case invalidRequest
    case makeRequestFailed
}

// MARK: - Response Object

struct ProfileResponse: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}
