import Foundation
import SwiftKeychainWrapper

// MARK: - Errors

enum ProfileImageServiceErrors: Error {
    case invalidToken
    case makeRequestFailed
}

// MARK: - Response Objects

struct ProfileImageResponse: Decodable {
    let large: String
}

struct PublicProfileResponse: Decodable {
    let profileImage: ProfileImageResponse
}

// MARK: - ProfileImageService

final class ProfileImageService {
    
    // MARK: Properties
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private let publicProfileApiURL = "/users/:username"
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var oauth2TokenStorage = KeychainWrapper.standard
    
    // MARK: Private Constructors
    
    private init() {}
    
    // MARK: - Fetch image
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        do {
            let token = try validateToken()
            task?.cancel()
            guard let request = makeUrlRequest(for: username, with: token) else {
                throw ProfileImageServiceErrors.makeRequestFailed
            }
            executeRequest(request, completion: completion)
        } catch {
            AppLogger.error(error)
            completion(.failure(error))
        }
    }
    
    func clearAvatarURL() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    
    private func validateToken() throws -> String {
        guard let token = oauth2TokenStorage.string(forKey: Constants.keychainOAuthTokenKeyName) else {
            throw ProfileImageServiceErrors.invalidToken
        }
        return token
    }
    
    private func makeUrlRequest(for username: String, with token: String) -> URLRequest? {
        guard let defaultURL = Constants.defaultBaseURL else { return nil }
        let url = defaultURL.appendingPathComponent(publicProfileApiURL.replacingOccurrences(of: ":username", with: username))
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func executeRequest(_ request: URLRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let task = urlSession.objectTask(for: request) { [weak self] (response: Result<PublicProfileResponse, Error>) in
            self?.task = nil
            switch response {
            case .success(let profileResponse):
                self?.handleSuccessResponse(profileResponse)
                completion(.success(profileResponse.profileImage.large))
                self?.notifyAvatarChanged(url: profileResponse.profileImage.large)
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func handleSuccessResponse(_ response: PublicProfileResponse) {
        avatarURL = response.profileImage.large
    }
    
    private func notifyAvatarChanged(url: String) {
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": url]
        )
    }
}
