import Foundation
@testable import ImageFeed

final class ImagesListViewSpy: ImagesListViewProtocol {
    private(set) var updateTableViewAnimatedCallCount = 0
    private(set) var oldCountCaptured: Int?
    private(set) var newCountCaptured: Int?
    
    private(set) var reloadCellIndexPath: IndexPath?
    private(set) var showErrorMessageCallCount = 0
    private(set) var hideProgressHUDCallCount = 0

    var onUpdateTableViewAnimated: ((Int, Int) -> Void)?
    var photos: [Photo] = []
       var fetchPhotosNextPageCallCount = 0
       var changeLikeCallArguments: (photoId: String, isLike: Bool)?

       func fetchPhotosNextPage() {
           fetchPhotosNextPageCallCount += 1
       }

       func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
           changeLikeCallArguments = (photoId: photoId, isLike: isLike)
           completion(.success(()))
       }
    
        func updateTableViewAnimated(oldCount: Int, newCount: Int) {
            updateTableViewAnimatedCallCount += 1
            oldCountCaptured = oldCount
            newCountCaptured = newCount
            onUpdateTableViewAnimated?(oldCount, newCount)
        }

    func reloadCell(at indexPath: IndexPath) {
        reloadCellIndexPath = indexPath
    }

    func showErrorMessage() {
        showErrorMessageCallCount += 1
    }

    func hideProgressHUD() {
        hideProgressHUDCallCount += 1
    }
}

