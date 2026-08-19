import XCTest
@testable import ImageFeed

@MainActor
final class ImageFeed_ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterAssignsViewCorrectly() {
        //given
        let viewControllerSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListViewControllerPresenter()
        
        //when
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        //then
        XCTAssertNotNil(presenter.view)
    }
    
    func testPresenterFetchNextPageIfNeeded() {
        //given
        let presenter = ImagesListPresenterSpy()
        
        //when
        presenter.fetchNextPageIfNeeded(forRowAt: 0)
        
        //then
        XCTAssertTrue(presenter.fectchNextPageCalled)
    }
}
