import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewControllerPresenterProtocol?
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
    }
}
