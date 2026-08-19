import XCTest
@testable import ImageFeed

@MainActor
final class ImageFeed_ProfileTest: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterAssignViewCorrectly() {
        //given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfileViewControllerPresenter()
        
        //when
        viewControllerSpy.presenter = presenter
        
        //then
        XCTAssertNotNil(presenter.view)
        
    }
}
