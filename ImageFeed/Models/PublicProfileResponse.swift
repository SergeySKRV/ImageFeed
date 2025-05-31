import Foundation

// MARK: - Response Objects

struct ProfileImageResponse: Decodable {
    let large: String
}

struct PublicProfileResponse: Decodable {
    let profileImage: ProfileImageResponse
}
