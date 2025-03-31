import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Static Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer?
    private let gradientHeight: CGFloat = 30
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
        setupImageGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
    }
    
    // MARK: - Configuration
    private func configureCell() {
        dateLabel.textColor = .white
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        cellImage.contentMode = .scaleAspectFill
        cellImage.layer.masksToBounds = true
    }
    
    // MARK: - Gradient Setup
    private func setupImageGradient() {
        guard gradientLayer == nil else { return }
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(white: 0, alpha: 0.0).cgColor,
            UIColor(white: 0, alpha: 0.3).cgColor,
            UIColor(white: 0, alpha: 0.5).cgColor
        ]
        gradient.locations = [0, 0.7, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.name = "gradientLayer"
        
        cellImage.layer.addSublayer(gradient)
        gradientLayer = gradient
    }
    
    // MARK: - Layout
    func updateGradientFrame() {
        guard cellImage.bounds.size != .zero else { return }
        
        if gradientLayer == nil { setupImageGradient() }
        
        gradientLayer?.frame = CGRect(
            x: 0,
            y: cellImage.bounds.height - gradientHeight,
            width: cellImage.bounds.width,
            height: gradientHeight
        )
    }
}
