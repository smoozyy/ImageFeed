import UIKit

final class SingleImageViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet private var imageView: UIImageView!
        
    //MARK: Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    //MARK: didLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
