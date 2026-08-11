import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    //MARK: Propetries
    private var avatarImageView: UIImageView?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var nameLabel: UILabel?
    private var profileLabel: UILabel?
    private var descriptionLabel: UILabel?
    private let profileService = ProfileService.shared
    private var profileLogoutService = ProfileLogoutService.shared
    private var animationLayers = Set<CALayer>()
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            guard let self else {return}
            self.updateAvatar()
        }
        
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
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        updateAvatar()
        
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
        let avatarGradient = createGradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 70, height: 70)), cornerRadius: 35)
        animationLayers.insert(avatarGradient)
        avatarImageView?.layer.addSublayer(avatarGradient)
        
        let nameLabelGradient = createGradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: , height: )), cornerRadius: )
    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel?.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        profileLabel?.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel?.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {return}
        
        print("imageURL: \(url)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        
        
        let proccessor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView?.kf.indicatorType = .activity
        avatarImageView?.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(proccessor),
                .scaleFactor(UIScreen.main.scale), /// учитываем масштаб экрана
                .cacheOriginalImage, /// кэшируем изображение
                .forceRefresh /// игнорируем кэш, чтобы обновить
            ]) { result in
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
        
        
    }
    
    @objc private func didTapButton() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Нет", style: .default)
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.profileLogoutService.logout()
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }
}
