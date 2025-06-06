import Foundation
@testable import ImageFeed

// MARK: - ProfileViewSpy

final class ProfileViewSpy: ProfileViewProtocol {
    // MARK: - Properties
    
    private(set) var updateProfileInfoCalled = false
    private(set) var lastProfileName: String?
    private(set) var lastProfileLogin: String?
    private(set) var lastProfileDescription: String?
    
    private(set) var updateAvatarCalled = false
    private(set) var lastAvatarURL: URL?
    
    // MARK: - ProfileViewProtocol
    
    func updateProfileInfo(name: String?, login: String?, description: String?) {
        updateProfileInfoCalled = true
        lastProfileName = name
        lastProfileLogin = login
        lastProfileDescription = description
    }
    
    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
        lastAvatarURL = url
    }
}

// MARK: - ProfileResponse Stub Extension

struct ProfileResponse {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

extension ImageFeed.ProfileResponse {
    static func stub(
        username: String = "test_user",
        firstName: String = "Test",
        lastName: String? = "User",
        bio: String? = "Bio"
    ) -> ImageFeed.ProfileResponse {
        ImageFeed.ProfileResponse(
            username: username,
            firstName: firstName,
            lastName: lastName,
            bio: bio
        )
    }
}
