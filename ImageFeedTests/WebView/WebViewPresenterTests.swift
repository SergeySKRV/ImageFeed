import XCTest
@testable import ImageFeed
import WebKit

// MARK: - WebViewPresenterTests

final class WebViewPresenterTests: XCTestCase {
    private var sut: WebViewPresenter!
    private var viewControllerSpy: WebViewViewControllerSpy!
    private var authHelperSpy: AuthHelperSpy!
    
    override func setUp() {
        super.setUp()
        viewControllerSpy = WebViewViewControllerSpy()
        authHelperSpy = AuthHelperSpy()
        sut = WebViewPresenter(view: viewControllerSpy, authHelper: authHelperSpy)
    }
    
    override func tearDown() {
        sut = nil
        viewControllerSpy = nil
        authHelperSpy = nil
        super.tearDown()
    }
    
    // MARK: - testPresenterCallsLoadRequest
    
    func testPresenterCallsLoadRequest() {
        // Given
        let viewControllerSpy = WebViewViewControllerSpy()
        let authHelperStub = AuthHelper()
        let presenter = WebViewPresenter(view: viewControllerSpy, authHelper: authHelperStub)
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewControllerSpy.loadRequestCalled)
        XCTAssertNotNil(viewControllerSpy.lastRequest)
    }
    
    // MARK: - testProgressHiddenWhenOne
    
    func testProgressHiddenWhenOne() {
        // When
        sut.didUpdateProgressValue(1.0)
        
        // Then
        XCTAssertTrue(viewControllerSpy.setProgressHiddenCalled)
        XCTAssertTrue(viewControllerSpy.lastProgressHidden == true)
        XCTAssertEqual(viewControllerSpy.lastProgressValue, 1.0)
    }
    
    // MARK: - testCodeFromURL
    
    func testCodeFromURL() {
        // Given
        let expectedCode = "test_code"
        let authHelper = AuthHelper()
        
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        components.queryItems = [URLQueryItem(name: "code", value: expectedCode)]
        
        guard let testURL = components.url else {
            XCTFail("Не удалось создать URL из компонентов")
            return
        }
        
        // When
        let extractedCode = authHelper.code(from: testURL)
        
        // Then
        XCTAssertEqual(extractedCode, expectedCode)
    }
    
    // MARK: - testAuthHelperAuthURL
    
    func testAuthHelperAuthURL() {
        // Given
        let configuration = AuthConfiguration.standart
        let authHelper = AuthHelper(configuration: configuration)
        
        // When
        guard let url = authHelper.authURL() else {
            XCTFail("URL не должен быть nil")
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            XCTFail("Не удалось создать URLComponents из URL")
            return
        }
        
        // Then
        XCTAssertEqual(components.scheme, "https")
        XCTAssertTrue(url.absoluteString.contains(configuration.authURLString))
        
        guard let queryItems = components.queryItems else {
            XCTFail("Query параметры должны существовать")
            return
        }
        
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "client_id", value: configuration.accessKey)))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "redirect_uri", value: configuration.redirectURI)))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "response_type", value: "code")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "scope", value: configuration.accessScope)))
    }
}
