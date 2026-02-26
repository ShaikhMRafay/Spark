import Foundation

final class CacheManager {

    static let shared = CacheManager()
    private init() {}

    private let cacheFileName = "rosters_cache.json"

    private var cacheURL: URL {
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent(cacheFileName)
    }

    /// Save data to cache
    func save<T: Encodable>(_ object: T) {
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: cacheURL, options: .atomic)
        } catch {
            print("Cache save error: \(error.localizedDescription)")
        }
    }

    /// Load data from cache
    func load<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Clear cache
    func clear() {
        try? FileManager.default.removeItem(at: cacheURL)
    }
}
