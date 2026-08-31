import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewControllerPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    
    func updateTableViewAnimated(addedIndexes: [Int]) {
        updateTableViewAnimatedCalled = true
    }
    
    func showLikeErrorAlert() {
    }
}
