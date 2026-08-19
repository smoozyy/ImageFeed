import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewControllerPresenterProtocol? { get set }
    func updateAvatar(with url: URL)
    func updateProfileDetails(name: String, login: String, bio: String)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    //MARK: Propetries
    var presenter: ProfileViewControllerPresenterProtocol?
    private var avatarImageView: UIImageView?
    private var nameLabel: UILabel?
    private var profileLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var animationLayers = Set<CALayer>()
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let nameLabel = UILabel()
        let profileLabel = UILabel()
        let descriptionLabel = UILabel()
        let avatarImageView = UIImageView()
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "exit_icon") ?? UIImage(),
            target: self,
            action: #selector(didTapButton)
        )
        
        exitButton.tintColor = .red
        nameLabel.textColor = .ypWhiteIOS
        profileLabel.textColor = .ypGrayIOS
        descriptionLabel.textColor = .ypWhiteIOS
        nameLabel.font = UIFont(name:"SFPro-Bold" , size: 23)
        profileLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        descriptionLabel.font = UIFont(name: "SFPro-Regular", size: 13)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        view.addSubview(exitButton)
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(profileLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            
            //MARK: imageViewConstraints
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16 ),
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            
            //MARK: exitButtonConstraints
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            //MARK: labelsConstraints
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            profileLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])
        
        self.avatarImageView = avatarImageView
        self.nameLabel = nameLabel
        self.profileLabel = profileLabel
        self.descriptionLabel = descriptionLabel
        
        showSkeleton()
        
        if presenter == nil {
            let presenter = ProfileViewControllerPresenter()
            presenter.view = self
            self.presenter = presenter
        }
        presenter?.viewDidLoad()
    }
    
    
    
    
    //MARK: Private Methods
    private func createGradientLayer(frame: CGRect, cornerRadius: CGFloat) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.locations = [0.0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x:0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0.0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        return gradient
    }
    
    private func showSkeleton() {
        view.layoutIfNeeded()
        guard
            let avatarImageView = avatarImageView,
            let nameLabel = nameLabel,
            let profileLabel = profileLabel,
            let descriptionLabel = descriptionLabel
        else {return}
        let avatarGradient = createGradientLayer(frame: avatarImageView.bounds, cornerRadius: 35)
        animationLayers.insert(avatarGradient)
        avatarImageView.layer.addSublayer(avatarGradient)
        
        let nameLabelGradient = createGradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 200 , height: 30 )), cornerRadius: 9 )
        animationLayers.insert(nameLabelGradient)
        nameLabel.layer.addSublayer(nameLabelGradient)
        
        let profileLabelGradient = createGradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)), cornerRadius: 9)
        animationLayers.insert(profileLabelGradient)
        profileLabel.layer.addSublayer(profileLabelGradient)
        
        let descriptionLabelGradient = createGradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 22)), cornerRadius: 9)
        animationLayers.insert(descriptionLabelGradient)
        descriptionLabel.layer.addSublayer(descriptionLabelGradient)
    }
    
    private func removeSkeleton() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel?.text = name
        profileLabel?.text = login
        descriptionLabel?.text = bio
    }
    
    func updateAvatar(with url: URL) {
        let placeHolder = makeAvatarPlaceholder()
        let processor = makeAvatarProcessor()
        setAvatarImage(from: url, placeholder: placeHolder, processor: processor)
        
    }
    
    private func makeAvatarPlaceholder() -> UIImage? {
        return UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .medium))
    }
    
    private func makeAvatarProcessor() -> ImageProcessor {
        return RoundCornerImageProcessor(cornerRadius: 35)
    }
    
    private func setAvatarImage(from url: URL, placeholder: UIImage?, processor: ImageProcessor) {
        avatarImageView?.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { [weak self] _ in
            self?.removeSkeleton()
        }
    }
    
    @objc private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Нет", style: .default)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else {return}
            self.presenter?.didTapLogout()
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
    
}
