import UIKit

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.minimumZoomScale = 0.1
        view.maximumZoomScale = 1.25
        view.delegate = self
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .navBackButtonWhite), for: .normal)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .shareButton), for: .normal)
        return button
    }()
    
    // MARK: - Buttons Handlers
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    func setImage(imageUrl: URL) {
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success(let response):
                self.rescaleAndCenterImageInScrollView(image: response.image)
            case .failure:
                self.showError { self.setImage(imageUrl: imageUrl) }
            }
        }
    }
    
    // MARK: - Configure UI
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubviews(scrollView, backButton, shareButton, imageView)
        scrollView.addSubviews(imageView)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        scrollView.pin
            .top(view.topAnchor)
            .leading(view.leadingAnchor)
            .trailing(view.trailingAnchor)
            .bottom(view.bottomAnchor)
        
        backButton.pin
            .top(view.safeAreaLayoutGuide.topAnchor, offset: 9)
            .leading(view.safeAreaLayoutGuide.leadingAnchor, offset: 8)
            .width(48)
            .height(48)
        
        shareButton.pin
            .bottom(view.safeAreaLayoutGuide.bottomAnchor, offset: -17)
            .centerX(to: view.centerXAnchor)
            .width(50)
            .height(50)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showError(retryAction: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { _ in retryAction() }))
        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
