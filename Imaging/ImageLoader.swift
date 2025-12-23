import Foundation

/// Thin wrapper around URLSession for image downloads, with URLCache configured.
struct ImageLoader {
    private let session: URLSession

    init(session: URLSession = URLSession(configuration: ImageLoader.defaultConfiguration())) {
        self.session = session
    }

    func fetch(url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        // Prefer speed: use cached data when available, fall back to network.
        // Our app-owned DiskImageCache is the real persistence layer anyway.
        request.cachePolicy = .returnCacheDataElseLoad

        request.setValue("image/*", forHTTPHeaderField: "Accept")
        return try await session.data(for: request)
    }

    static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // Shared URLCache so multiple URLSessions (if any) cooperate.
        // Tune as needed.
        let memoryCapacity = 80 * 1024 * 1024 // 80MB
        let diskCapacity = 250 * 1024 * 1024 // 250MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        config.urlCache = cache
        URLCache.shared = cache

        // Respect per-request policies (we set it above).
        config.requestCachePolicy = .useProtocolCachePolicy
        return config
    }
}
