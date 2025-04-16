import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    
    @IBOutlet private weak var webView: WKWebView!
    
    
    @IBAction func didTapBackButton(_ sender: Any) {
        //TODO: реализовать функцию кнопки.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        
        guard let url  = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
