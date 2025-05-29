import ProgressHUD

enum ProgressHUDConfigurator {
    static func configure() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = .ypBlack
        ProgressHUD.colorAnimation = .ypGray
    }
}
