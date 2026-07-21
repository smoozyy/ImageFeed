import Foundation

struct UserResult: Codable {
    let profileImage: SmallImage
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    struct SmallImage: Codable {
        let small: String
    }
}

final class ProfileImageService {
    
    //MARK: Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {
    }
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    //MARK: Private methods
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = makeProfileImageURL(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self else {return}
                do{
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    self.avatarURL = userResult.profileImage.small
                    completion(.success(userResult.profileImage.small))
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    func makeProfileImageURL(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
