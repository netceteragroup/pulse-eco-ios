import Foundation

class FavouritesProvider {
    static let shared = FavouritesProvider()

    private var favorites: [String: [String]] = [:] // [CityName : [SensorId]]

    init() {
        loadFavorites()
    }

    func favorites(forCity city: String) -> [String] {
        if favorites[city.lowercased()] == nil {
            favorites[city.lowercased()] = []
        }
        return favorites[city.lowercased()]!
    }

    func add(favorite: String, forCity city: String) {
        var favoritesForCity = favorites(forCity: city)
        favoritesForCity.append(favorite)
        favorites[city.lowercased()] = favoritesForCity
        saveFavorites()
    }

    func remove(favorite: String, forCity city: String) {
        var favoritesForCity = favorites(forCity: city)
        if let favoriteIndex = favoritesForCity.firstIndex(of: favorite) {
            favoritesForCity.remove(at: favoriteIndex)
            favorites[city.lowercased()] = favoritesForCity
        }
        saveFavorites()
    }

    private func loadFavorites() {
        if let diskFavorites = NSDictionary(contentsOf: favoritesPath()) {
            favorites = diskFavorites as! [String: [String]]
        } else {
            favorites = [:]
            saveFavorites()
        }
    }

    private func saveFavorites() {
        NSDictionary(dictionary: favorites).write(to: favoritesPath(), atomically: true)
    }

    private func favoritesPath() -> URL {
        return documentsDirectory().appendingPathComponent("favorites.plist")
    }

    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}
