import UIKit

// MARK: - Class

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar")
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor.ypWhite
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.ypGray
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.ypWhite
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(didTapLogoutButton))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.ypRed
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupContent()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = UIColor.ypBlack
    }
    
    private func setupContent() {
        [profileImage, logoutButton, nameLabel, usernameLabel, descriptionLabel].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Profile Image (70x70)
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            // Logout Button
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // Username Label
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLogoutButton() {
        OAuth2TokenStorage.shared.removeToken()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
}
