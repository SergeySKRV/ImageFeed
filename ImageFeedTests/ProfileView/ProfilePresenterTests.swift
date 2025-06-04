import XCTest
@testable import ImageFeed

// MARK: - ProfilePresenterTests

final class ProfilePresenterTests: XCTestCase {
    private var presenter: ProfilePresenter!
    private var viewSpy: ProfileViewSpy!
    private var profileServiceStub: ProfileServiceStub!
    private var profileImageServiceStub: ProfileImageServiceStub!
    private var profileLogoutServiceStub: ProfileLogoutServiceStub!

    override func setUp() {
        super.setUp()
        
        viewSpy = ProfileViewSpy()
        profileServiceStub = ProfileServiceStub(profile: nil)
        profileImageServiceStub = ProfileImageServiceStub(avatarURL: nil)
        profileLogoutServiceStub = ProfileLogoutServiceStub()

        presenter = ProfilePresenter(
            view: viewSpy,
            profileService: profileServiceStub,
            profileImageService: profileImageServiceStub,
            profileLogoutService: profileLogoutServiceStub
        )
    }

    override func tearDown() {
        presenter = nil
        viewSpy = nil
        profileServiceStub = nil
        profileImageServiceStub = nil
        profileLogoutServiceStub = nil
        super.tearDown()
    }

    // MARK: - testUpdateProfileInfoOnViewDidLoad

    func testUpdateProfileInfoOnViewDidLoad() {
        // Given
        let response = ImageFeed.ProfileResponse.stub(
            username: "test",
            firstName: "Test",
            lastName: "User",
            bio: "Bio"
        )
        let profile = Profile(from: response)
        profileServiceStub = ProfileServiceStub(profile: profile)
        presenter = makePresenter()

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(viewSpy.updateProfileInfoCalled)
        XCTAssertEqual(viewSpy.lastProfileName, "Test User")
        XCTAssertEqual(viewSpy.lastProfileLogin, "@test")
        XCTAssertEqual(viewSpy.lastProfileDescription, "Bio")
    }

    // MARK: - testUpdateAvatarOnViewDidLoad

    func testUpdateAvatarOnViewDidLoad() {
        // Given
        profileImageServiceStub = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.jpg")
        presenter = makePresenter()

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(viewSpy.updateAvatarCalled)
        XCTAssertNotNil(viewSpy.lastAvatarURL)
        XCTAssertEqual(viewSpy.lastAvatarURL?.absoluteString, "https://example.com/avatar.jpg")
    }

    // MARK: - testSubscribeToAvatarUpdatesTriggersReload

    func testSubscribeToAvatarUpdatesTriggersReload() {
        // Given
        profileImageServiceStub = ProfileImageServiceStub(avatarURL: "https://example.com/old.jpg")
        presenter = makePresenter()
        presenter.viewDidLoad()

        let newURL = "https://example.com/new.jpg"
        profileImageServiceStub.avatarURL = newURL

        // When
        NotificationCenter.default.post(
            name: ProfileImageServiceStub.didChangeNotification,
            object: nil
        )

        // Then
        XCTAssertNotNil(viewSpy.lastAvatarURL)
        XCTAssertEqual(viewSpy.lastAvatarURL?.absoluteString, newURL)
    }
    
    // MARK: - testLogoutCallsLogoutAndShowsSplash

    func testLogoutCallsLogoutAndShowsSplash() {
        // Given
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            XCTFail("Не удалось получить UIWindow")
            return
        }
        let originalRootVC = window.rootViewController

        defer {
            window.rootViewController = originalRootVC
        }

        // When
        presenter.logout()

        // Then
        XCTAssertTrue(profileLogoutServiceStub.logoutCalled)
        guard let splashVC = window.rootViewController as? SplashViewController else {
            XCTFail("Должен быть установлен SplashViewController")
            return
        }
        XCTAssertNotNil(splashVC)
    }

    // MARK: - Private Methods

    private func makePresenter() -> ProfilePresenter {
        ProfilePresenter(
            view: viewSpy,
            profileService: profileServiceStub,
            profileImageService: profileImageServiceStub,
            profileLogoutService: profileLogoutServiceStub
        )
    }
}
