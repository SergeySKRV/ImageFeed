import Foundation

// MARK: - NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
    case noData
}

// MARK: - URLSession Extension

extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[Network Error]: \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[Network Error]: Invalid response type")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("[Server Error]: HTTP status code \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    print("[Network Error]: No data received")
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[Decoding Error]: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            }
        }
        return task
    }
}
