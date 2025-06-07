import UIKit
import ProgressHUD

// MARK: - UIBlockingProgressHUD Class

final class UIBlockingProgressHUD {
    
    // MARK: - Private Properties
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    // MARK: - Public Methods
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
