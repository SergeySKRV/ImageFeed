import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    private(set) var loadRequestCalled = false
    private(set) var lastRequest: URLRequest?
    private(set) var setProgressValueCalled = false
    private(set) var lastProgressValue: Float?
    private(set) var setProgressHiddenCalled = false
    private(set) var lastProgressHidden: Bool?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
        lastRequest = request
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
        lastProgressValue = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
        lastProgressHidden = isHidden
    }
}

final class AuthHelperSpy: AuthHelperProtocol {
    var authRequestCalled = false
    var codeFromURLCalled = false
    var stubAuthRequest: URLRequest?
    var stubCode: String?
    
    func authRequest() -> URLRequest? {
        authRequestCalled = true
        return stubAuthRequest ?? URLRequest(url: URL(string: "https://test.com")!)
    }
    
    func code(from url: URL) -> String? {
        codeFromURLCalled = true
        return stubCode
    }
}
