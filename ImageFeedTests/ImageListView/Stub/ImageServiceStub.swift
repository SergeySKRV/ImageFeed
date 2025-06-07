import Foundation
@testable import ImageFeed

final class ImageServiceStub: ImageListServiceProtocol {
    
    // MARK: - Properties
    
    var photos: [Photo] = []
    var fetchPhotosNextPageCallCount = 0
    var changeLikeCallArguments: (photoId: String, isLike: Bool)?
    var changeLikeError: Error?
    var onFetchPhotosNextPage: (() -> Void)?
    
    static var didChangeNotification = Notification.Name("didChangeNotification")
    
    
    // MARK: - ImageListServiceProtocol Methods
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCallCount += 1
        onFetchPhotosNextPage?()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCallArguments = (photoId: photoId, isLike: isLike)
        if let error = changeLikeError {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}
