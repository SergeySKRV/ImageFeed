import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
}

enum AuthServiceError: Error {
    case invalidRequest
    case makeRequestFailed
}


final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
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
            case .failure(_):
                let contextError = NSError(
                    domain: "OAuth2Service.fetchAuthToken",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Error fetching token: $error.localizedDescription)"]
                )
                AppLogger.error(contextError)
                completion(.failure(contextError))
            }
        }
        
        self.task = task
        
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.oauthTokenURL) else {
            let urlComponentsError = NSError(
                domain: "OAuth2Service",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey : "Error creating URLComponents"]
            )
            AppLogger.error(urlComponentsError)
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
            let urlCreationError = NSError(
                domain: "OAuth2Service",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey : "Error creating URL"]
            )
            AppLogger.error(urlCreationError)
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
