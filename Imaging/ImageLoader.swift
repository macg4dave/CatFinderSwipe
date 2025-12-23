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
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        return try await session.data(for: request)
    }

    static func defaultConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // Tune as needed.
        let memoryCapacity = 100 * 1024 * 1024 // 100MB
        let diskCapacity = 300 * 1024 * 1024 // 300MB
        config.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        config.requestCachePolicy = .useProtocolCachePolicy
        return config
    }
}
