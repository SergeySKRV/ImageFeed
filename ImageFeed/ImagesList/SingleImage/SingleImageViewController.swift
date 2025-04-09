import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        updateImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerImageIfNeeded()
    }
    
    // MARK: - IBActions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        shareImage()
    }
    
    // MARK: - Private Methods
    private func configureScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
    }
    
    private func updateImage() {
        guard isViewLoaded, let image = image else { return }
        
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImage()
    }
    
    private func rescaleAndCenterImage() {
        guard let image = image else { return }
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale,
                       max(scrollView.minimumZoomScale, min(hScale, vScale)))
        
        scrollView.zoomScale = scale
        centerImageIfNeeded()
    }
    
    private func centerImageIfNeeded() {
        guard imageView.image != nil else { return }
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
    }
    
    private func shareImage() {
        guard let image = image else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageIfNeeded()
    }
}
