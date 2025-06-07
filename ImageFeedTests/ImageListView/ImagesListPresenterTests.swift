import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    private var presenter: ImagesListPresenter!
    private var viewSpy: ImagesListViewSpy!
    private var imageServiceStub: ImageServiceStub!
    
    override func setUp() {
        super.setUp()
        viewSpy = ImagesListViewSpy()
        imageServiceStub = ImageServiceStub()
        presenter = ImagesListPresenter(view: viewSpy)
        presenter.set(imageService: imageServiceStub)
    }
    
    override func tearDown() {
        presenter = nil
        viewSpy = nil
        imageServiceStub = nil
        super.tearDown()
    }
    
    // MARK: - testDidLoadCallsFetchPhotosNextPage
    
    func testDidLoadCallsFetchPhotosNextPage() {
        // Given
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertEqual(imageServiceStub.fetchPhotosNextPageCallCount, 1)
    }
    
    // MARK: - testDidScrollToLastRowCallsFetchNextPage
    
    func testDidScrollToLastRowCallsFetchNextPage() {
        // When
        presenter.didScrollToLastRow()
        
        // Then
        XCTAssertEqual(imageServiceStub.fetchPhotosNextPageCallCount, 1)
    }
    
    // MARK: - testUpdatePhotosTriggersBatchUpdate
    
    func testUpdatePhotosTriggersBatchUpdate() {
        // Given
        let photo1 = Photo.stub(id: "1")
        let photo2 = Photo.stub(id: "2")
        
        imageServiceStub.photos = [photo1, photo2]
        presenter.setPhotos([])
        
        let expectation = self.expectation(description: "updateTableViewAnimated called")
        viewSpy.onUpdateTableViewAnimated = { _, _ in
            expectation.fulfill()
        }
        
        // When
        presenter.updatePhotos()
        
        waitForExpectations(timeout: 1.0)
        
        // Then
        XCTAssertEqual(presenter.photos.count, 2)
        XCTAssertEqual(viewSpy.updateTableViewAnimatedCallCount, 1)
        XCTAssertEqual(viewSpy.oldCountCaptured, 0)
        XCTAssertEqual(viewSpy.newCountCaptured, 2)
    }
    
    // MARK: - testChangeLikeUpdatesPhotoAndReloadsCell
    
    func testChangeLikeUpdatesPhotoAndReloadsCell() {
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
        XCTAssertEqual(viewSpy.hideProgressHUDCallCount, 1)
    }
    
    // MARK: - testChangeLikeFailureShowsError
    
    func testChangeLikeFailureShowsError() {
        // Given
        let photo = Photo.stub(id: "test_id", isLiked: false)
        imageServiceStub.photos = [photo]
        presenter.setPhotos([photo])
        
        let error = NSError(domain: "Test", code: 1)
        imageServiceStub.changeLikeError = error
        
        // When
        presenter.changeLike(for: 0)
        
        // Then
        XCTAssertEqual(viewSpy.showErrorMessageCallCount, 1)
        XCTAssertEqual(viewSpy.hideProgressHUDCallCount, 1)
    }
    
}
