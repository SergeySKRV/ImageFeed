import Foundation
@testable import ImageFeed

// MARK: - PhotosResponse Stub

extension PhotosResponse {
    static func stub(
        id: String = "test_id",
        width: Int = 800,
        height: Int = 600,
        createdAt: Date? = Date(),
        description: String? = "Test photo",
        urls: PhotoUrlsResponse = PhotoUrlsResponse.thumbAndLargeStub(),
        likedByUser: Bool = false
    ) -> PhotosResponse {
        PhotosResponse(
            id: id,
            width: width,
            height: height,
            createdAt: createdAt,
            description: description,
            urls: urls,
            likedByUser: likedByUser
        )
    }
}

// MARK: - PhotoUrlsResponse Stub

extension PhotoUrlsResponse {
    static func thumbAndLargeStub(
        thumb: String = "https://example.com/thumb.jpg",
        full: String = "https://example.com/full.jpg"
    ) -> PhotoUrlsResponse {
        PhotoUrlsResponse(thumb: thumb, full: full)
    }
}
