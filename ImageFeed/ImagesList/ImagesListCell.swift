import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    //MARK: Properties
    private var animationLayers = Set<CALayer>()
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
        removeSkeleton()
    }
    
    //MARK: Skeleton method's
    
    func showSkeleton() {
        layoutIfNeeded()
        
        let gradient = CAGradientLayer()
        gradient.frame = cellImageView.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0.0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(gradient)
        cellImageView.layer.addSublayer(gradient)

    }
    
    func removeSkeleton() {
        animationLayers.forEach { $0.removeFromSuperlayer()}
        animationLayers.removeAll()
    }
}
