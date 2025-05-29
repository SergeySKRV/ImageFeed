import UIKit
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private var profileService: ProfileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileLogoutService = ProfileLogoutService.shared

    // MARK: - UI Elements
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(resource: .avatar)
                .withTintColor(.ypGray, renderingMode: .alwaysOriginal)
        )
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_novikova"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGray
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello world"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.tintColor = .ypRed
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        subscribeToAvatarUpdates()
        updateProfileData()
        updateAvatar()
    }

    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Да", style: .cancel, handler: { [weak self] _ in
            self?.profileLogoutService.logout()
            self?.showSplashScreen()
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        present(alert, animated: true)
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

    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubviews(avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }

    private func setupConstraints() {
        avatarImageView.pin
            .width(70)
            .height(70)
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 32)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 16)

        logoutButton.pin
            .width(44)
            .height(44)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor, offset: -16)
            .centerY(to: avatarImageView.centerYAnchor)

        nameLabel.pin
            .leading(avatarImageView.leadingAnchor)
            .top(avatarImageView.bottomAnchor, offset: 8)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor, offset: -16)

        loginNameLabel.pin
            .top(nameLabel.bottomAnchor, offset: 8)
            .leading(nameLabel.leadingAnchor)
            .trailing(nameLabel.trailingAnchor)

        descriptionLabel.pin
            .top(loginNameLabel.bottomAnchor, offset: 8)
            .leading(loginNameLabel.leadingAnchor)
            .trailing(nameLabel.trailingAnchor)
    }

    // MARK: - Avatar Updates
    
    private func subscribeToAvatarUpdates() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
    }

    // MARK: - Profile Data Handling
    
    private func updateProfileData() {
        guard let profile = profileService.profile else {
            return
        }
        nameLabel.text = profile.fullName
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }

    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        AppLogger.info("Updating avatar from $url)")
        avatarImageView.kf.setImage(with: url)
    }
}
