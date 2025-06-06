import Foundation

// MARK: - Модель изображения

struct ImageModel: Codable, Equatable {
    let id: String
    let url: URL
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}

// MARK: - Протокол

protocol FavoritesImageServiceProtocol {
    func isFavorited(imageID: String) -> Bool
    func toggleFavorite(image: ImageModel)
    func getFavorites() -> [ImageModel]
    
    var favoritesDidChange: (() -> Void)? { get set }
}

// MARK: - Реализация

final class FavoritesImageService: FavoritesImageServiceProtocol {
    static let shared = FavoritesImageService()
    
    private let userDefaults = UserDefaults.standard
    private let key = "favoriteImages"
    
    var favoritesDidChange: (() -> Void)?
    
    private init() {}
    
    // MARK: - Проверка наличия в избранном
    
    func isFavorited(imageID: String) -> Bool {
        return favoriteIDs.contains(imageID)
    }
    
    // MARK: - Переключение лайка
    
    func toggleFavorite(image: ImageModel) {
        if isFavorited(imageID: image.id) {
            remove(image: image)
        } else {
            add(image: image)
        }
    }
    
    // MARK: - Добавление в избранное
    
    private func add(image: ImageModel) {
        var current = favoriteIDs
        current.append(image.id)
        save(ids: current)
        notifyUpdate()
    }
    
    // MARK: - Удаление из избранного
    
    private func remove(image: ImageModel) {
        let current = favoriteIDs.filter { $0 != image.id }
        save(ids: current)
        notifyUpdate()
    }
    
    // MARK: - Получить все избранные изображения
    
    func getFavorites() -> [ImageModel] {
        return favoriteIDs.compactMap { id in
            // Здесь можно запросить реальный URL с сервера
            // Для примера используем заглушку
            URL(string: "https://picsum.photos/id/$id)/200/300")  // демо-URL
                .map { ImageModel(id: id, url: $0) }
        }
    }
    
    // MARK: - Приватные методы для работы с UserDefaults
    
    private var favoriteIDs: [String] {
        guard let data = userDefaults.data(forKey: key),
              let ids = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return ids
    }
    
    private func save(ids: [String]) {
        guard let data = try? JSONEncoder().encode(ids) else { return }
        userDefaults.set(data, forKey: key)
    }
    
    private func notifyUpdate() {
        DispatchQueue.main.async {
            self.favoritesDidChange?()
        }
    }
}
