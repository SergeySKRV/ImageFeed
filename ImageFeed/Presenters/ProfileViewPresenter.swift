import Foundation
import UIKit

protocol ProfileViewProtocol: AnyObject {
    func updateProfileInfo(name: String?, login: String?, description: String?)
    func updateAvatar(url: URL?)
    
    var lastProfileName: String? { get }
    var lastProfileLogin: String? { get }
    var lastProfileDescription: String? { get }
    var lastAvatarURL: URL? { get }
}
// MARK: - ProfilePresenter

final class ProfilePresenter {
    
    // MARK: - Properties
    
    private weak var view: ProfileViewProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    
    // MARK: - Init
    
    init(
        view: ProfileViewProtocol,
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.view = view
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        updateProfileInfo()
        updateAvatar()
        subscribeToAvatarUpdates()
    }
    
    func logout() {
        profileLogoutService.logout()
        showSplashScreen()
    }
    
    // MARK: - Private Methods
    
    private func updateProfileInfo() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileInfo(
            name: profile.fullName,
            login: profile.loginName,
            description: profile.bio
        )
    }
    
    private func updateAvatar() {
        guard let avatarURLString = profileImageService.avatarURL,
              let url = URL(string: avatarURLString) else { return }
        AppLogger.info("Updating avatar from $url)")
        view?.updateAvatar(url: url)
    }
    
    private func subscribeToAvatarUpdates() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func showSplashScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Unable to get UIWindow")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
}
