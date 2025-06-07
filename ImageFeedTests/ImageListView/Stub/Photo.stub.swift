import Foundation
@testable import ImageFeed

// MARK: - Photo Stub

extension Photo {
    static func stub(
        id: String = "test_id",
        size: CGSize = CGSize(width: 100, height: 100),
        createdAt: Date? = Date(),
        welcomeDescription: String? = nil,
        thumbImageURL: String = "https://example.com/thumb.jpg",
        largeImageURL: String = "https://example.com/large.jpg",
        isLiked: Bool = false
    ) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
