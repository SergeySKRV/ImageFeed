import XCTest
@testable import ImageFeed

// MARK: - ProfileViewControllerTests

final class ProfileViewControllerTests: XCTestCase {
    private var viewController: ProfileViewController!
    private var profileServiceStub: ProfileServiceStub!
    private var profileImageServiceStub: ProfileImageServiceStub!
    private var viewSpy: ProfileViewSpy!

    override func setUp() {
        super.setUp()

        // Given
        let response = ImageFeed.ProfileResponse.stub(
            username: "jane",
            firstName: "Jane",
            lastName: "Doe",
            bio: "Bio"
        )
        let profile = Profile(from: response)

        profileServiceStub = ProfileServiceStub(profile: profile)
        profileImageServiceStub = ProfileImageServiceStub(avatarURL: "https://example.com/avatar.jpg")
        viewSpy = ProfileViewSpy()

        let presenter = ProfilePresenter(
            view: viewSpy,
            profileService: profileServiceStub,
            profileImageService: profileImageServiceStub
        )

        let viewController = ProfileViewController()
        viewController.set(presenter: presenter)

        self.viewController = viewController

        // When
        _ = viewController.view 
        presenter.viewDidLoad()
    }

    // MARK: - testViewControllerUpdatesUIOnLoad

    func testViewControllerUpdatesUIOnLoad() {
        // Then
        XCTAssertEqual(viewSpy.lastProfileName, "Jane Doe")
        XCTAssertEqual(viewSpy.lastProfileLogin, "@jane")
        XCTAssertEqual(viewSpy.lastProfileDescription, "Bio")
    }

    // MARK: - testViewControllerLoadsAvatarImage
    
    func testViewControllerLoadsAvatarImage() {
        // Then
        XCTAssertNotNil(viewSpy.lastAvatarURL, "lastAvatarURL не должен быть nil")
        XCTAssertEqual(
            viewSpy.lastAvatarURL?.absoluteString,
            "https://example.com/avatar.jpg",
            "URL аватарки должен совпадать с ожидаемым"
        )
    }

    override func tearDown() {
        viewController = nil
        profileServiceStub = nil
        profileImageServiceStub = nil
        viewSpy = nil
        super.tearDown()
    }
}
