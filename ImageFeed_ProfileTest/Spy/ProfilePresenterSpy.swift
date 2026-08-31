import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfileViewControllerPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true 
    }
}

