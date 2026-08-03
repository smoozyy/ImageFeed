import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let urls: UrlsResult
    let id: String
    let createdAt: String?
    let updatedAt: String?
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case urls
        case id = "id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width = "width"
        case height = "height"
        case color = "color"
        case blurHash = "blur_hash"
        case likes = "likes"
        case likedByUser = "liked_by_user"
        case description = "description"
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case raw = "raw"
        case full = "full"
        case regular = "regular"
        case small = "small"
        case thumb = "thumb"
    }
}

final class ImagesListService {
    
    //MARK: Properties
    
    private let urlSession = URLSession.shared
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask?
    
    //...
    
    //MARK: Private Method's
    
    func fetchPhotosNextPage() {
        if task != nil {
            return
        }
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result< [PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.task = nil
                
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self)
                case .failure(let error):
                    print(error)
                }
            }
        }
        task?.resume()
    }
    
    func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension Photo {
    
    private static let dateFormatter = ISO8601DateFormatter()
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        if let createdAtString = result.createdAt {
            self.createdAt = Photo.dateFormatter.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
