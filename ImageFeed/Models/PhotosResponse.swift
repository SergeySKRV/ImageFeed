import Foundation

// MARK: - PhotosResponse

struct PhotosResponse: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let urls: PhotoUrlsResponse
    let likedByUser: Bool

    func toPhoto() -> Photo {
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: createdAt,
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

// MARK: - PhotoUrlsResponse

struct PhotoUrlsResponse: Decodable {
    let thumb: String
    let full: String
}

// MARK: - ChangeLikePhotosResponse

struct ChangeLikePhotosResponse: Decodable {
    let photo: PhotosResponse
}
