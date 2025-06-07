import Foundation

// MARK: - ProfileService

final class ProfileService: ProfileServiceProtocol {
    
    // MARK: - Properties
    
    static let shared = ProfileService()
    private let currentUserURI = "/me"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Fetch Profile
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeRequest(token: token) else {
            AppLogger.error(ProfileServiceError.makeRequestFailed)
            completion(.failure(ProfileServiceError.makeRequestFailed))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (response: Result<ProfileResponse, Error>) in
            self?.task = nil
            
            switch response {
            case .success(let profileResponse):
                let profile = Profile(from: profileResponse)
                self?.profile = profile
                completion(.success(profile))
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
        profile = nil
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(token: String) -> URLRequest? {
        let url = Constants.defaultBaseURL.appendingPathComponent(currentUserURI)
        
        guard url.isFileURL || URL(string: url.absoluteString) != nil else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
