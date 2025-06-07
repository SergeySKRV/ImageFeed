import UIKit
import WebKit

// MARK: - WebViewViewControllerDelegate Protocol

protocol WebViewViewControllerDelegate: AnyObject {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewController Class

final class WebViewViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = "UnsplashWebView"
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .default
        progressView.progressTintColor = .ypBlack
        return progressView
    }()
    
    // MARK: - Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private var presenter: WebViewPresenterProtocol?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = WebViewPresenter(view: self)
        setupUI()
        setupConstraints()
        setupProgressObservation()
        setupWebView()
        presenter?.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent && !isBeingDismissed && !isMovingToParent {
            delegate?.webViewViewControllerDidCancel(self)
        }
    }
    
    // MARK: - Setup UI Methods
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        view.addSubviews(webView, progressView)
        webView.navigationDelegate = self
    }
    
    private func setupConstraints() {
        progressView.pin
            .top(view.safeAreaLayoutGuide.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
        
        webView.pin
            .top(view.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(view.bottomAnchor)
    }
    
    private func setupProgressObservation() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 self?.presenter?.didUpdateProgressValue(self?.webView.estimatedProgress ?? 0)
             }
        )
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
    }
}

// MARK: - WebViewViewControllerProtocol Implementation

extension WebViewViewController: WebViewViewControllerProtocol {
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: - WKNavigationDelegate Implementation

extension WebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if let code = presenter?.code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
