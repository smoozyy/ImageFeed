import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewControllerPresenterProtocol? { get set }
    func updateTableViewAnimated(addedIndexes: [Int])
    func showLikeErrorAlert()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    //MARK: Outlets
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: Properties
    var presenter: ImagesListViewControllerPresenterProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if presenter == nil {
            let presenter = ImagesListViewControllerPresenter()
            presenter.view = self
            self.presenter = presenter
        }
        
        presenter?.viewDidLoad()
    }
    
    //MARK: Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photo(at: indexPath.row),
                let url = URL(string: photo.largeImageURL)
            else{
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.imageURL = url
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated(addedIndexes: [Int]) {
        let indexPaths = addedIndexes.map { IndexPath(row: $0, section: 0) }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Ок",
            style: .default
        )
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.fetchNextPageIfNeeded(forRowAt: indexPath.row)
    }
}

//MARK: extensions

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount ?? 0
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
        guard let photo = presenter?.photo(at: indexPath.row) else {return}
        
        configureCellImage(for: cell, with: photo.thumbImageURL)
        configureCellDate(for: cell, with: photo.createdAt)
        configureCellLikeButton(for: cell, isLiked: photo.isLiked)
    }
    
    
    
    
    
    private func configureCellImage(for cell: ImagesListCell, with urlString: String){
        guard let url = URL(string: urlString) else { return }
        cell.showSkeleton()
        cell.cellImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .stub)
        ) { [weak cell] result in
            cell?.removeSkeleton()
        }
    }
    
    private func configureCellDate(for cell: ImagesListCell, with date: Date?) {
        if let date = date, let dataString = presenter?.formateDate(date) {
            cell.dateLabel.text = dataString
        } else {
            cell.dateLabel.text = ""
        }
    }
    
    private func configureCellLikeButton(for cell: ImagesListCell, isLiked: Bool) {
        let likeImageName = isLiked ? "like_button_on" : "like_button_off"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
        
        
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
        let photo = presenter?.photo(at: indexPath.row)
        UIBlockingProgressHUD.show()
        
        presenter?.changeLike(for: indexPath.row) { [weak self, weak cell] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self, let cell = cell else {return}
            
            if case .success = result {
                if let updatedPhoto = self.presenter?.photo(at: indexPath.row) {
                    self.configureCellLikeButton(for: cell, isLiked: updatedPhoto.isLiked)
                }
            }
        }
        
        
    }
}

