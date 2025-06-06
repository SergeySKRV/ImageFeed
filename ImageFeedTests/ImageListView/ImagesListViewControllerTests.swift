import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    private var viewController: ImagesListViewController!
    private var presenter: ImagesListPresenter!
    private var imageServiceStub: ImageServiceStub!
    private var viewSpy: ImagesListViewSpy!
    
    override func setUp() {
        super.setUp()
        
        viewSpy = ImagesListViewSpy()
        imageServiceStub = ImageServiceStub()
        
        presenter = ImagesListPresenter(view: viewSpy)
        presenter.set(imageService: imageServiceStub)
        
        viewController = ImagesListViewController()
        viewController.set(presenter: presenter)
        
        viewController.loadViewIfNeeded()
        
    }
    
    override func tearDown() {
        viewController = nil
        presenter = nil
        imageServiceStub = nil
        viewSpy = nil
        super.tearDown()
    }
    
    // MARK: - testDidLoadTriggersFetchPhotosNextPage
    
    func testDidLoadTriggersFetchPhotosNextPage() {
        // Given — setup уже в setUp()
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertEqual(imageServiceStub.fetchPhotosNextPageCallCount, 1)
    }
    
    // MARK: - testWillDisplayLastItemTriggersFetchNextPage
    
    func testWillDisplayLastItemTriggersFetchNextPage() {
        // Given
        let photo1 = Photo.stub(id: "1")
        let photo2 = Photo.stub(id: "2")
        
        imageServiceStub.photos = [photo1, photo2]
        _ = viewController.view
        
        XCTAssertEqual(imageServiceStub.fetchPhotosNextPageCallCount, 1)
        
        // When
        viewController.triggerWillDisplayLastItem()
        
        // Then
        XCTAssertEqual(imageServiceStub.fetchPhotosNextPageCallCount, 2)
    }
    
    // MARK: - testChangeLikeCallsPresenterChangeLike
    
    func testChangeLikeCallsPresenterChangeLike() {
        // Given
        let photo = Photo.stub(id: "test_id", isLiked: false)
        imageServiceStub.photos = [photo]
        presenter.setPhotos([photo])
        
        // When
        presenter.changeLike(for: 0)
        
        // Then
        XCTAssertEqual(imageServiceStub.changeLikeCallArguments?.photoId, "test_id")
        XCTAssertTrue(imageServiceStub.changeLikeCallArguments?.isLike ?? false)
        XCTAssertEqual(viewSpy.reloadCellIndexPath, IndexPath(row: 0, section: 0))
    }
}
