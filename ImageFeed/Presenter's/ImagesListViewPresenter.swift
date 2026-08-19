import Foundation
import WebKit

public protocol ImagesListViewControllerPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int {get}
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func fetchNextPageIfNeeded(forRowAt index: Int)
    func changeLike(for index: Int, completion: @escaping ((Result<Void, Error>) -> Void))
    func formateDate(_ date: Date) -> String
}

final class ImagesListViewControllerPresenter: ImagesListViewControllerPresenterProtocol {
    
    //MARK: Properties
    weak var view: ImagesListViewControllerProtocol?
    private var imagesListObserver: NSObjectProtocol?
    private(set) var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var photosCount: Int {
        return photos.count
    }
    //MARK: Methods
    
    func viewDidLoad() {
        setupImagesObserver()
        imagesListService.fetchPhotosNextPage()
        
        
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    func fetchNextPageIfNeeded(forRowAt index: Int) {
        if index + 1 == photosCount {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func changeLike(for index: Int, completion: @escaping ((Result<Void, Error>) -> Void)) {
        let photo = photos[index]
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .success:
                self.photos = self.imagesListService.photos
                completion(.success(()))
            case .failure(let error):
                self.view?.showLikeErrorAlert()
                completion(.failure(error))
            }
        }
    }
    
    func formateDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    //MARK: Private method's
    
    private func setupImagesObserver() {
        imagesListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else {return}
                self.updatePhotosAnyNotifyView()
            }
    }
    
    private func updatePhotosAnyNotifyView() {
        let oldPhotosCount = photos.count
        let newPhotosCount = imagesListService.photos.count
        
        if oldPhotosCount != newPhotosCount {
            photos = imagesListService.photos
            let indexArray = Array(oldPhotosCount..<newPhotosCount)
            view?.updateTableViewAnimated(addedIndexes: indexArray)
        }
    }
    
    
}
