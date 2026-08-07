import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    //MARK: Properties
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: Outlets
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    //MARK: Actions

    @IBAction private  func likeButtonClicked() {
        delegate?.imageCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
}
