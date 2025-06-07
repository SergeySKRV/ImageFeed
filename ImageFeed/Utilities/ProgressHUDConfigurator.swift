import ProgressHUD

// MARK: - ProgressHUD Configuration

enum ProgressHUDConfigurator {
    static func configure() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .ypBlack
        ProgressHUD.colorAnimation = .ypGray
    }
}
