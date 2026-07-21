import UIKit

final class ProfileViewController: UIViewController {
    
    //MARK: Propetries
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var nameLabel: UILabel?
    private var profileLabel: UILabel?
    private var descriptionLabel: UILabel?
    private let profileService = ProfileService.shared
    
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
        updateAvatar()
            
        let nameLabel = UILabel()
        let profileLabel = UILabel()
        let descriptionLabel = UILabel()
        let profileImage = UIImage(named: "profile_icon")
        let imageView = UIImageView(image: profileImage)
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(profileLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            
            //MARK: imageViewConstraints
            
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16 ),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            
            //MARK: exitButtonConstraints
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            //MARK: labelsConstraints
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            profileLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])
        
        self.nameLabel = nameLabel
        self.profileLabel = profileLabel
        self.descriptionLabel = descriptionLabel
        
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
        
        
    }
    
    
    
    
    //MARK: Private Methods
    
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
        
        //TODO: code
    }
    
    @objc private func didTapButton() {
    }
    
    
    
    
}
