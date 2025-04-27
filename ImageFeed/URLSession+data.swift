import UIKit

// MARK: - Enum

enum NetworkError: Error, CustomStringConvertible {
    case httpStatusCode(Int, Data?)
    case urlRequestError(Error)
    case urlSessionError
    
    var description: String {
        switch self {
        case .httpStatusCode(let statusCode, let data):
            if let data = data, let errorMessage = parseErrorMessage(from: data) {
                return "HTTP Status Code: \(statusCode), Message: \(errorMessage)"
            } else {
                return "HTTP Status Code: \(statusCode)"
            }
        case .urlRequestError(let error):
            return "URL Request Error: \(error.localizedDescription)"
        case .urlSessionError:
            return "URL Session Error"
        }
    }
    
    private func parseErrorMessage(from data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["message"] as? String {
                return message
            }
        } catch {
            print("Failed to parse error data: \(error)")
        }
        return nil
    }
}

// MARK: - Extension

extension URLSession {
    
    // MARK: - Methods
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode, data)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        task.resume()
        
        return task
    }
}
