import Foundation

// MARK: - ImageListService

final class ImageListService {
    
    // MARK: - Constants
    
    static let didChangeNotification = Notification.Name("ImageListServiceDidChange")
    static let shared = ImageListService()
    
    private let photosApiUrl = ImagesListServiceConstants.photosApiUrl
    private let likesApiUrl = ImagesListServiceConstants.likesApiUrl
    private let perPageCount = ImagesListServiceConstants.perPageCount
    
    // MARK: - Properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var oauth2TokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    private var isFetching = false
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Public API
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard !isFetching else {
            AppLogger.info("Fetch is already in progress")
            return
        }
        
        guard let token = oauth2TokenStorage.token else {
            return
        }
        
        let pageNumber = lastLoadedPage + 1
        
        guard let request = makeRequestForImageList(
            forPageNumber: pageNumber,
            andPerPageCount: perPageCount,
            andToken: token
        ) else {
            AppLogger.error("Error creating URLRequest")
            return
        }
        
        isFetching = true
        
        let task = urlSession.objectTask(for: request) { [weak self] (
            result: Result<[PhotosResponse], Error>
        ) in
            guard let self else { return }
            
            self.isFetching = false
            
            switch result {
            case .success(let photosResponse):
                AppLogger.info("Fetched \(photosResponse.count) photos")
                
                let newPhotos = photosResponse.map { $0.toPhoto() }
                let uniqueNewPhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains { $0.id == newPhoto.id }
                }
                
                if !uniqueNewPhotos.isEmpty {
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    self.lastLoadedPage = pageNumber
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self
                    )
                } else {
                    AppLogger.info("No new photos to add")
                }
                
            case .failure(let error):
                AppLogger.error("Failed to fetch photos: \(error)")
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Logout logic
    
    func logout() {
        photos = []
        lastLoadedPage = 0
        task?.cancel()
        task = nil
        isFetching = false
    }
    
    // MARK: - Private Methods (Network Requests)
    
    private func makeRequestForImageList(forPageNumber pageNumber: Int, andPerPageCount perPageCount: Int, andToken token: String) -> URLRequest? {
        guard
            let baseUrl = Constants.defaultBaseURL,
            var urlComponents = URLComponents(url: baseUrl.appendingPathComponent(photosApiUrl), resolvingAgainstBaseURL: true)
        else {
            AppLogger.error("Error creating URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(pageNumber)),
            URLQueryItem(name: "per_page", value: String(perPageCount)),
        ]
        
        guard let url = urlComponents.url else {
            AppLogger.error("Error creating URL from URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    // MARK: - Likes
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard let token = oauth2TokenStorage.token else {
            return
        }
        
        guard let request = makeRequestForLikes(photoId: photoId, andToken: token, isLike: isLike) else {
            AppLogger.error("Error creating URLRequest for likes")
            return
        }
        
        let task = urlSession.dataTask(for: request) {[weak self] (result: Result<_, Error>) in
            switch result {
            case .success:
                self?.updateLike(photoId: photoId)
                completion(.success(()))
            case .failure(let error):
                AppLogger.error("Failed to change like: $error)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    private func makeRequestForLikes(photoId: String, andToken token: String, isLike: Bool) -> URLRequest? {
        guard let defaultURL = Constants.defaultBaseURL else {
            return nil
        }
        
        let url = defaultURL.appendingPathComponent(
            self.likesApiUrl.replacingOccurrences(of: ":id", with: photoId)
        )
        var request = URLRequest(url: url)
        if isLike {
            request.httpMethod = HTTPMethod.post.rawValue
        } else {
            request.httpMethod = HTTPMethod.delete.rawValue
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func updateLike(photoId: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]
            
            let newPhoto = Photo(
               id: photo.id,
               size: photo.size,
               createdAt: photo.createdAt,
               welcomeDescription: photo.welcomeDescription,
               thumbImageURL: photo.thumbImageURL,
               largeImageURL: photo.largeImageURL,
               isLiked: !photo.isLiked
            )
            
            photos[index] = newPhoto
            NotificationCenter.default.post(
                name: ImageListService.didChangeNotification,
                object: self
            )
        }
    }
}
