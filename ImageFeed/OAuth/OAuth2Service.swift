import UIKit
import WebKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {
    }
    
    //MARK: Private methods
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
     
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = URLSession.shared.data(for: request) { result in
            switch result{
            case .failure(let error):
                print(error)
                completion(.failure(error))
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    completion(.success(token))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
    
}
