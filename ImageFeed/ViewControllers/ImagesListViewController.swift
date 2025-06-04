import UIKit

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    // MARK: - Properties
    
    private var presenter: ImagesListPresenter!
    private let showSingleImageSegueIdentifier: String = "ShowSingleImage"
    
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
        presenter = ImagesListPresenter(view: self)
        subscribeToImageServiceUpdates()
        presenter.viewDidLoad()
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
    
    private func subscribeToImageServiceUpdates() {
        NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presenter.updatePhotos()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        guard let photo = presenter.photo(at: indexPath.row) else { return cell }
        
        guard let photoUrl = URL(string: photo.thumbImageURL) else {
            return cell // или установить placeholder
        }
        
        cell.configure(photoUrl, andDate: photo.createdAt, andIsLiked: photo.isLiked)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == presenter.photos.count {
            presenter.didScrollToLastRow()
        }
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
    
    func reloadCell(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func showErrorMessage() {
        let alert = buildAlert(
            withTitle: "Что-то пошло не так",
            andMessage: "Не удалось изменить лайк"
        )
        present(alert, animated: true)
    }
    
    func hideProgressHUD() {
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photos[indexPath.row]
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
        if presenter.didSelectRow(at: indexPath) {
            let viewController = SingleImageViewController()
            guard let photo = presenter.photo(at: indexPath.row),
                  let photoUrl = URL(string: photo.largeImageURL) else { return }
            viewController.setImage(imageUrl: photoUrl)
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.changeLike(for: indexPath.row)
    }
}
