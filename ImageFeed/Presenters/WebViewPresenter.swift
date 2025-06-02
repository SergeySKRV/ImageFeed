import Foundation
import WebKit

protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from navigationAction: WKNavigationAction) -> String?
}

protocol WebViewViewControllerProtocol: AnyObject {
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    var authHelper: AuthHelperProtocol
    
    init(view: WebViewViewControllerProtocol, authHelper: AuthHelperProtocol = AuthHelper()) {
        self.view = view
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        view?.load(request: request)
        didUpdateProgressValue(0)
        loadAuthView()
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = abs(newProgressValue - 1.0) <= 0.001
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url else { return nil }
        return authHelper.code(from: url)
    }
    
    private func loadAuthView() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
    }
}
