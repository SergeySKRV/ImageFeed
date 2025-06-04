import Foundation
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadCell(at indexPath: IndexPath)
    func showErrorMessage()
    func hideProgressHUD()
}

final class ImagesListPresenter {
    
    // MARK: - Properties
    
    private weak var view: ImagesListViewProtocol?
    private let imageService = ImageListService.shared
    private(set) var photos: [Photo] = []
    
    // MARK: - Init
    
    init(view: ImagesListViewProtocol) {
        self.view = view
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        photos = imageService.photos
        imageService.fetchPhotosNextPage()
    }
    
    func didScrollToLastRow() {
        imageService.fetchPhotosNextPage()
    }
    
    func didSelectRow(at indexPath: IndexPath) -> Bool {
        guard indexPath.row < photos.count else { return false }
        return true
    }
    
    func photo(at index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return photos[index]
    }
    
    func changeLike(for index: Int) {
        guard let photo = photo(at: index) else { return }
        
        imageService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imageService.photos
                self.view?.reloadCell(at: IndexPath(row: index, section: 0))
            case .failure:
                self.view?.showErrorMessage()
            }
            self.view?.hideProgressHUD()
        }
    }
    
    // MARK: - Private Methods
    
    func updatePhotos() {
        let oldCount = photos.count
        let newCount = imageService.photos.count
        
        if oldCount != newCount {
            photos = imageService.photos
            DispatchQueue.main.async { [weak self] in
                self?.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
            }
        }
    }
}
