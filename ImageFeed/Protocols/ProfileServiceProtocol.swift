import Foundation

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?

    convenience init(profile: Profile?) {
        self.init()
        self.profile = profile
    }
}
