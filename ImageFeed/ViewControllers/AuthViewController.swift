import UIKit
import SwiftKeychainWrapper

// MARK: - AuthViewControllerDelegate Protocol

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

// MARK: - AuthViewController Class

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    
    private let oauth2Service = OAuth2Service.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage(resource: .splashScreenLogo))
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AuthViewControllerConstants.loginButtonTitle, for: .normal)
        button.tintColor = .ypBlack
        button.backgroundColor = .ypWhite
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup UI Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubviews(logoImageView, loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
    
    private func setupConstraints() {
        logoImageView.pin
            .centerX(to: view.centerXAnchor)
            .centerY(to: view.centerYAnchor)
        
        loginButton.pin
            .height(48)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 16)
            .trailing(view.safeAreaLayoutGuide.trailingAnchor, offset: -16)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, offset: -90)
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        let viewController = WebViewViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
        AppLogger.info("User cancelled authentication")
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        oauth2Service.fetchAuthToken(from: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
            switch result {
            case .success(let token):
                KeychainWrapper.standard.set(token, forKey: Constants.keychainOAuthTokenKeyName)
                delegate?.didAuthenticate(self)
                
            case .failure(let error):
                AppLogger.error("Error fetching token: $error)")
                let alert = self.buildAlert(
                    withTitle: AuthViewControllerConstants.errorAlertTitle,
                    andMessage: AuthViewControllerConstants.errorAlertMessage
                )
                self.present(alert, animated: true)
            }
        }
    }
}
