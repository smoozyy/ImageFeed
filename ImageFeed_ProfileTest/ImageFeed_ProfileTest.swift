import XCTest
@testable import ImageFeed

@MainActor
final class ImageFeed_ProfileTest: XCTestCase {
    
    private func makeSUT() -> (
        viewController: ProfileViewController,
        presenter: ProfilePresenterSpy
    ) {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return (viewController, presenter)
    }
    
    func testViewControllerCallsViewDidLoad() {
        //Given
        let (viewController, presenter) = makeSUT()
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterAssignViewCorrectly() {
        //Given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfileViewControllerPresenter()
        
        //When
        viewControllerSpy.presenter = presenter
        
        //Then
        XCTAssertNotNil(presenter.view)
        
    }
}
