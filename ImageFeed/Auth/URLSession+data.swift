import UIKit
import WebKit


enum NetworkError: Error {  // 1
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    print("[URLSession.data]: Network error - HTTP status code: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
                print("[URLSession.data]: Network error - URLRequest error: \(error.localizedDescription)")
            } else {
                print("[URLSession.data]: URLSession unknown error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
        func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void
        ) -> URLSessionTask {
            let decoder = JSONDecoder()
            let task = data(for: request) { (result: Result<Data, Error>) in
                switch result {
                case .success(let data):
                    do{
                        let decodedObject = try decoder.decode(T.self, from: data)
                        completion(.success(decodedObject))
                    } catch {
                        if let decodingError = error as? DecodingError {
                            print("[URLSession.objectTask]: DecodingError: \(decodingError), Data: \(String(data: data, encoding: .utf8) ?? "")")
                        } else {
                            print("[URLSession.objectTask]: DecodinError: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                        }
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("[URLSession.objectTask] NetworkError: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            return task
        }
    }

