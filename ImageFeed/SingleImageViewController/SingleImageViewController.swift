import UIKit

final class SingleImageViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    //MARK: Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            if let unwrappedImage = image {
                rescaleAndCenterImageInScrollView(image: unwrappedImage)
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction private func didTapBackButton(_ sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let unwrappedImage = image else {
            print("Image is nil, cannot share")
            return
        }
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [unwrappedImage], applicationActivities: nil)
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.sharePlay,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.collaborationCopyLink,
            UIActivity.ActivityType.print
        ]
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: didLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        if let unwrappedImage = image {
            imageView.frame.size = unwrappedImage.size
            rescaleAndCenterImageInScrollView(image: unwrappedImage)
        }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    //MARK: Private methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

//MARK: Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


