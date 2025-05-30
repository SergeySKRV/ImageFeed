import Foundation

// MARK: - Network Error

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case missingResponse
    case decodingError(Error, Data)
}

// MARK: - Shared JSONDecoder

private extension JSONDecoder {
    static let shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - URLSession Extension

extension URLSession {
    
    // MARK: - Data Task
    
    func dataTask(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            let result = Self.processResponse(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        task.resume()
        return task
    }

    // MARK: - Object Task (Decodable)

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder.shared.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    AppLogger.error("Decoding failed: $error), data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(error, data)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }

    // MARK: - Response Processing

    private static func processResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<Data, Error> {
        if let error = error {
            return .failure(NetworkError.urlRequestError(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(NetworkError.missingResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            return .failure(NetworkError.httpStatusCode(httpResponse.statusCode))
        }

        guard let data = data else {
            return .failure(NetworkError.urlSessionError)
        }

        return .success(data)
    }
}
