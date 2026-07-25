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
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else {return}
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
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
