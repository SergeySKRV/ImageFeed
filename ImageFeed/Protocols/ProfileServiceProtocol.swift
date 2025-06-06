import Foundation

// MARK: - ProfileServiceProtocol

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

// MARK: - ProfileServiceStub

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?
    
    convenience init(profile: Profile?) {
        self.init()
        self.profile = profile
    }
}
