import UIKit

extension UIViewController {
    func buildAllert(withTitle title: String, andMessage message: String, andOkButtonTitle okButtonTitle: String = "Ok") -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert
            .addAction(
                UIAlertAction(
                    title: okButtonTitle,
                    style: .default
                )
            )
        return alert
    }
}
