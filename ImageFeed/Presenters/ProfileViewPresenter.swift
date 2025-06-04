import Foundation
import UIKit

protocol ProfileViewProtocol: AnyObject {
    func updateProfileInfo(name: String?, login: String?, description: String?)
    func updateAvatar(url: URL?)
}

final class ProfilePresenter {
    
    // MARK: - Properties
    
    private weak var view: ProfileViewProtocol?
    private let profileService: ProfileService = ProfileService.shared
    private let profileImageService: ProfileImageService = ProfileImageService.shared
    private let profileLogoutService: ProfileLogoutService = ProfileLogoutService.shared
    
    // MARK: - Init
    
    init(view: ProfileViewProtocol) {
        self.view = view
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
    
    func avatarURL() -> URL? {
        guard let avatarStringURL = profileImageService.avatarURL else { return nil }
        return URL(string: avatarStringURL)
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
        let url = avatarURL()
        view?.updateAvatar(url: url)
        AppLogger.info("Updating avatar from \(String(describing: url))")
    }
    
    private func subscribeToAvatarUpdates() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.view?.updateAvatar(url: self.avatarURL())
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
