import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case missingResponse
}

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
        decoder.dateDecodingStrategy = .iso8601
        let task = dataTask(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    AppLogger.error("Decoding response body error: \(error), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                AppLogger.error("Error fetching token: \(error)")
                completion(.failure(error))
            }
        }
        return task
    }
    
    private static func processResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, Error> {
        if let error = error {
            AppLogger.error(error, data: data)
            return .failure(NetworkError.urlRequestError(error))
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.error(NetworkError.missingResponse)
            return .failure(NetworkError.missingResponse)
        }
        
        let statusCode = httpResponse.statusCode
        
        guard (200..<300).contains(statusCode), let data = data else {
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                AppLogger.error("Response data: \(dataString)")
            }
            return .failure(NetworkError.httpStatusCode(statusCode))
        }
        return .success(data)
    }
}
