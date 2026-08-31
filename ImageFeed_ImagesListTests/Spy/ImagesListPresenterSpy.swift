import Foundation
import UIKit
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListViewControllerPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled = false
    var fectchNextPageCalled = false
    var photosCount: Int = 0
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchNextPage() {
        fectchNextPageCalled = true
    }
    
    func changeLike(for index: Int, completion: @escaping ((Result<Void, Error>) -> Void)){
    }
    
    func formateDate(_ date: Date) -> String {
        return "26 августа 2026 г."
    }
    
    func photo(at index: Int) -> Photo {
        return Photo(
            id: "test",
            size: .zero,
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: false
        )
    }
    
    func fetchNextPageIfNeeded(forRowAt index: Int) {
    }
}

