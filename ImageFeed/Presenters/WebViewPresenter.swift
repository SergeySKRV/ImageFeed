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
    
    init(view: WebViewViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
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
            let url = navigationAction.request.url,
            url.isOAuthRedirectURL
        else { return nil }
        
        return url.queryParameterValue(forKey: "code")
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewViewControllerConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        view?.load(request: request)
    }
}
