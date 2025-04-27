import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Constants
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    // MARK: - Properties
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("Token exists: \(token), switching to tab bar controller")
            switchToTabBarController()
        } else {
            print("Token is nil, showing authentication screen")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration: No main window found.")
            return
        }
        
        guard let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            assertionFailure("Invalid Configuration: TabBarViewController not found.")
            return
        }
        
        window.rootViewController = tabBarController
    }
}

// MARK: - Segue Preparation

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                print("Токен получен: \(token)")
                self.storage.token = token
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("Ошибка получения токена: \(error)")
                self.showAlert(withTitle: "Ошибка", message: "Не удалось получить токен. Попробуйте снова.")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
