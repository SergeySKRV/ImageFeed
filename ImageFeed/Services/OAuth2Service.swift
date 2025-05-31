import Foundation

// MARK: - Models

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
}

enum AuthServiceError: Error {
    case invalidRequest
    case makeRequestFailed
}

// MARK: - OAuth2Service

final class OAuth2Service {
    
    // MARK: - Shared Instance
    
    static let shared = OAuth2Service()
    
    // MARK: - Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchAuthToken(from code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            AppLogger.error(AuthServiceError.invalidRequest)
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            AppLogger.error(AuthServiceError.makeRequestFailed)
            completion(.failure(AuthServiceError.makeRequestFailed))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            self?.task = nil
            self?.lastCode = nil
            
            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.accessToken))
            case .failure(let error):
                AppLogger.error("Error fetching token: \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.oauthTokenURL) else {
            AppLogger.error("Error creating URLComponents")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        guard let url = urlComponents.url else {
            AppLogger.error("Error creating URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
