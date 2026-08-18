import Foundation

public protocol ProfileViewControllerPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    
}

final class ProfileViewControllerPresenter: ProfileViewControllerPresenterProtocol {
    
    //MARK: Propertie's
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    //MARK: Public Method's
    func viewDidLoad() {
        setupAvatarObserver()
        
        updateProfileDetails()
        
        updateAvatar()
    }
    
    func didTapLogout() {
        profileLogoutService.logout()
    }
    
    private func setupAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else {return}
            self.updateAvatar()
        }
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {return}
        
        let name = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        let login = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        let bio = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : (profile.bio ?? "")
        
        view?.updateProfileDetails(name: name, login: login, bio: bio)
    }
    
    private func updateAvatar() {
        guard
            let avatarURLString = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURLString)
        else { return }
        
        view?.updateAvatar(with: url)
    }

}
