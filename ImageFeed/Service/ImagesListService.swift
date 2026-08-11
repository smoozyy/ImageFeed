import UIKit

struct LikeResultWrapper: Decodable {
    let photo: PhotoResult
}

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
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case raw
        case full
        case regular
        case small
        case thumb 
    }
}

final class ImagesListService {
    
    //MARK: Properties
    
    private var oauth2TokenStorage =  OAuth2TokenStorage.shared
    private var likeTask: URLSessionTask?
    static let shared = ImagesListService()
    private init() {
    }
    private let urlSession = URLSession.shared
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private var task: URLSessionTask?
    
    //...
    
    //MARK: Private Method's
    
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
                    for photo in newPhotos {
                        let isDuplicate = self.photos.contains { existingPhoto in
                            existingPhoto.id == photo.id
                        }
                        
                        if !isDuplicate {
                            self.photos.append(photo)
                        }
                    }
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
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        likeTask?.cancel()
        guard let token = oauth2TokenStorage.token else {
            print("[ImagesListService.changeLike]: Error - Failed to get token")
            return
        }
        guard let request = makeLikeRequest(token: token, photoId: photoId, isLike: isLike) else {
            return
        }
        likeTask = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResultWrapper, Error>) in
            guard let self else {return}
            DispatchQueue.main.async {
                self.likeTask = nil
                switch result {
                    case .success(let wrapper):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId}){
                        let updatedPhotoResult = wrapper.photo 
                        let newPhoto = Photo(from: updatedPhotoResult)
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
        }
        likeTask?.resume()
    }
    
    func makeLikeRequest(token: String, photoId: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func clean() {
        photos = []
        likeTask?.cancel()
        likeTask = nil
        task?.cancel()
        task = nil
        lastLoadedPage = nil
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
