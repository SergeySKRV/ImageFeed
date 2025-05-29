import Foundation

// MARK: - ProfileImageService

final class ProfileImageService {
    
    // MARK: - Properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private let publicProfileApiURL = ProfileImageServiceConstants.publicProfileApiURL
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var oauth2TokenStorage = Oauth2TokenStorage.shared
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Fetch Image
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let token = oauth2TokenStorage.token else {
            completion(.failure(ProfileImageServiceErrors.invalidToken))
            return
        }
        
        task?.cancel()
        
        guard let request = makeRequest(username: username, token: token) else {
            AppLogger.error(ProfileImageServiceErrors.makeRequestFailed)
            completion(.failure(ProfileImageServiceErrors.makeRequestFailed))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (response: Result<PublicProfileResponse, Error>) in
            self?.task = nil
            
            switch response {
            case .success(let profileResponse):
                self?.avatarURL = profileResponse.profileImage.large
                completion(.success(profileResponse.profileImage.large))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileResponse.profileImage.large]
                )
            case .failure(let error):
                AppLogger.error(error)
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Logout
    
    func logout() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(username: String, token: String) -> URLRequest? {
        guard let defaultURL = Constants.defaultBaseURL else {
            return nil
        }
        
        let url = defaultURL.appendingPathComponent(
            self.publicProfileApiURL.replacingOccurrences(of: ":username", with: username)
        )
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
