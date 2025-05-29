import UIKit

// MARK: - Protocol

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - UI Elements
    
    private lazy var cellImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(resource: .stub)
        view.kf.indicatorType = .activity
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var imageDate: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var isLikedStatus: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGradient()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - Configuration
    
    func configureWith(_ imageUrl: URL, andDate date: Date?, andIsLiked isLiked: Bool) {
        cellImage.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(resource: .stub),
            options: []
        )
        if let date = date {
            imageDate.text = date.imageCellDateString()
        }
        isLikedStatus.setImage(UIImage(named: getIsLikedImageName(isLiked: isLiked)), for: .normal)
    }
    
    func setIsLiked(isLiked: Bool) {
        isLikedStatus.setImage(UIImage(named: getIsLikedImageName(isLiked: isLiked)), for: .normal)
    }
    
    private func getIsLikedImageName(isLiked: Bool) -> String {
        return isLiked ? "like_button_on" : "like_button_off"
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        backgroundColor = .ypBlack
        selectionStyle = .none
        contentView.addSubviews(cellImage, gradientView, imageDate, isLikedStatus)
        isLikedStatus.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.1, green: 0.11, blue: 0.13, alpha: 0).cgColor,
            UIColor(red: 0.1, green: 0.11, blue: 0.13, alpha: 0.2).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.addSublayer(gradient)
    }
    
    private func updateGradientFrame() {
        if let gradient = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = gradientView.bounds
        }
    }
    
    private func setupConstraints() {
        let topAndBottomPadding: CGFloat = 4
        let leadingAndTrailingPadding: CGFloat = 16
        
        cellImage.pin
            .top(contentView.topAnchor, offset: topAndBottomPadding)
            .leading(contentView.leadingAnchor, offset: leadingAndTrailingPadding)
            .trailing(contentView.trailingAnchor, offset: -leadingAndTrailingPadding)
            .bottom(contentView.bottomAnchor, offset: -topAndBottomPadding)
        
        gradientView.pin
            .leading(cellImage.leadingAnchor)
            .trailing(cellImage.trailingAnchor)
            .bottom(cellImage.bottomAnchor)
            .height(30)
        
        imageDate.pin
            .leading(cellImage.leadingAnchor, offset: 8)
            .bottom(cellImage.bottomAnchor, offset: -8)
        
        isLikedStatus.pin
            .width(44)
            .height(44)
            .trailing(cellImage.trailingAnchor)
            .top(cellImage.topAnchor)
    }
    
    // MARK: - Actions
    
    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
