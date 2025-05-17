import UIKit

// MARK: - Enum

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case missingResponse
    
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
    
    func dataTask(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            let result = Self.processResponse(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        return task
    }
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = dataTask(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    // Создаём объект Error с описанием ошибки
                    let decodingError = NSError(
                        domain: "DecodingError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Decoding response body error: \(error.localizedDescription)"]
                    )
                    AppLogger.error(decodingError)
                    completion(.failure(error))
                }
                
            case .failure(let error):
                AppLogger.error(error)
                completion(.failure(error))
            }
        }
        return task
    }
    
    private static func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, Error> {
        if let error = error {
            AppLogger.error(error)
            return .failure(NetworkError.urlRequestError(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.error(NetworkError.missingResponse)
            return .failure(NetworkError.missingResponse)
        }

        let statusCode = httpResponse.statusCode

        guard (200..<300).contains(statusCode), let data = data else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {

                let responseDataError = NSError(
                    domain: "ResponseDataError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Response data: \(dataString)"]
                )
                AppLogger.error(responseDataError)
            }
            return .failure(NetworkError.httpStatusCode(statusCode))
        }

        return .success(data)
    }
}

extension UIViewController {
    func buildAllert(withTitle title: String, andMessage message: String, andOkButtonTitle okButtonTitle: String = "Ok") -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: okButtonTitle, style: .default))
        return alert
    }
}
