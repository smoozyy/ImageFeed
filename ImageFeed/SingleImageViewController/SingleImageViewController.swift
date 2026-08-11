import UIKit
import Kingfisher


final class SingleImageViewController: UIViewController {
    
    //MARK: Outlets
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    //MARK: Properties
    
    private var isImageLoaded: Bool = false
    var imageURL: URL?
    
    //MARK: Actions
    
    @IBAction private func didTapBackButton(_ sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let unwrappedImage = imageView.image else {
            print("Image is nil, cannot share")
            return
        }
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [unwrappedImage], applicationActivities: nil)
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.airDrop
        ] as? UIActivityItemsConfigurationReading
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.sharePlay,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.collaborationCopyLink,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.airDrop
        ]
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: didLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        
        scrollView.delegate = self
        loadImage()
    }
    
    //MARK: Private methods
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isImageLoaded,
                let image = imageView.image else { return }
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(hScale, vScale)
        let finalScale = max(scrollView.minimumZoomScale, min(scrollView.maximumZoomScale, scale))
        scrollView.setZoomScale(finalScale, animated: false)
        let newContentsSize = scrollView.contentSize
        let x = (newContentsSize.width - visibleRectSize.width ) / 2
        let y = (newContentsSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x:x,y:y), animated: false)
    }
    
    private func loadImage () {
        guard let imageURL else {return}
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageURL
        ) { [weak self] result in
            guard let self else {return}
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.isImageLoaded = true
            case .failure(let error):
                print("[SingleImageViewController.loadImage] Error: \(error.localizedDescription)")
                self.showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self else {return}
            self.loadImage()
        }
        alert.addAction(okAction)
        alert.addAction(retryAction)
        self.present(alert, animated: true)
    }
}

//MARK: Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


