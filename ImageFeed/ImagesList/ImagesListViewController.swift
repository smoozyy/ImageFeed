import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    //MARK: Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    
    
    //MARK: Properties
    
    private var imagesListObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            guard let self else {return}
            updateTableViewAnimated()
        }
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListService.fetchPhotosNextPage()
    }
    
    //MARK: Methods
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else{
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            guard let url = URL(string: photo.largeImageURL) else {return}
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        let oldPhotosCount = photos.count
        let newPhotosCount = imagesListService.photos.count
        
        if oldPhotosCount != newPhotosCount {
            photos = imagesListService.photos
            tableView.performBatchUpdates {
                let indexPaths = (oldPhotosCount..<newPhotosCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

//MARK: extensions

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        guard let url = URL(string: photo.thumbImageURL) else { return }
        cell.showSkeleton()
        cell.cellImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "stub")
        ) { [weak cell] result in
            cell?.removeSkeleton()
        }
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        let likeImage = UIImage(named: "like_button_\(photo.isLiked ? "on" : "off")")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let photo = photos[indexPath.row]
        
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {return}
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let updatedPhoto = self.photos[indexPath.row]
                let likeImage = UIImage(named: "like_button_\(updatedPhoto.isLiked ? "on" : "off" )")
                cell.likeButton.setImage(likeImage, for: .normal)
            case .failure(let error):
                print("[ImagesListViewController.imagesListcellDidTapLike]: Error - \(error.localizedDescription)")
                let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось поставить лайк", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
}

