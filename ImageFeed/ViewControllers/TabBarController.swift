import UIKit

// MARK: - TabBarController Class
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        configureViewControllers()
    }
    
    // MARK: - Appearance Setup
    
    private func setupAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .ypBlack
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypWhite
        tabBar.standardAppearance = tabBarAppearance
    }
    
    // MARK: - View Controllers Configuration
    
    private func configureViewControllers() {
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
