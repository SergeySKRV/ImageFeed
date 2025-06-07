import Foundation

// MARK: - ImageListServiceProtocol

protocol ImageListServiceProtocol {
    var photos: [Photo] { get set }
    static var didChangeNotification: Notification.Name { get }
    
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
