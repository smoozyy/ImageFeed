import XCTest
@testable import ImageFeed

@MainActor
final class ImageFeed_ImagesListTests: XCTestCase {
    
    private func makeSUT() -> (
        viewController: ImagesListViewController,
        presenter: ImagesListPresenterSpy
    ) {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        
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
    
    func testPresenterAssignsViewCorrectly() {
        //Given
        let viewControllerSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListViewControllerPresenter()
        
        //When
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        //Then
        XCTAssertNotNil(presenter.view)
    }
    
    func testPresenterFetchNextPageIfNeeded() {
        //Given
        let presenter = ImagesListPresenterSpy()
        
        //When
        presenter.fetchNextPageIfNeeded(forRowAt: 0)
        
        //Then
        XCTAssertTrue(presenter.fectchNextPageCalled)
    }
}
