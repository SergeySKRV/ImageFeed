import UIKit

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    private let showSingleImageSegueIdentifier: String = "ShowSingleImage"
    private let imageService = ImageListService.shared
    private var imageServiceObserver: NSObjectProtocol?
    private(set) var photos: [Photo] = []
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .ypBlack
        view.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        subscribeToImageServiceUpdates()
        imageService.fetchPhotosNextPage()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubviews(tableView)
    }
    
    private func setupConstraints() {
        tableView.pin
            .top(view.safeAreaLayoutGuide.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        guard let photoUrl = URL(string: photo.thumbImageURL) else { return }
        cell.configureWith(photoUrl, andDate: photo.createdAt, andIsLiked: photo.isLiked)
    }
    
    private func showSingleImage(for indexPath: IndexPath) {
        let viewController = SingleImageViewController()
        let photo = photos[indexPath.row]
        guard let photoUrl = URL(string: photo.largeImageURL) else { return }
        
        viewController.setImage(imageUrl: photoUrl)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    private func subscribeToImageServiceUpdates() {
        imageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageService.photos.count
        
        if oldCount != newCount {
            photos = imageService.photos
            DispatchQueue.main.async { [weak self] in
                self?.tableView.performBatchUpdates({
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    self?.tableView.insertRows(at: indexPaths, with: .automatic)
                }, completion: nil)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        if imageWidth == 0 {
            return 0
        }
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImage(for: indexPath)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    private enum LikeAllertCaptions {
        static let title = "Что-то пошло не так"
        static let message = "Не удалось изменить лайк"
    }
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imageService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                let alert = buildAllert(
                    withTitle: LikeAllertCaptions.title,
                    andMessage: LikeAllertCaptions.message
                )
                present(alert, animated: true)
                AppLogger.error("Error: \(error)")
            }
        }
    }
}
