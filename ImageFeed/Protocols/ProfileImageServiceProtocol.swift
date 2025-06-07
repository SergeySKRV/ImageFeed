import Foundation

// MARK: - ProfileImageServiceProtocol

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    static var didChangeNotification: Notification.Name { get }
}

// MARK: - ProfileImageServiceStub

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    convenience init(avatarURL: String?) {
        self.init()
        self.avatarURL = avatarURL
    }
}
