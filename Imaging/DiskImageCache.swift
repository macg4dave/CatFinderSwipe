import Foundation

/// A basic file-based image cache stored in the app's Caches directory.
actor DiskImageCache {
    private let baseURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.baseURL = caches.appendingPathComponent("CatFinderSwipeImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    func loadImage(for url: URL) -> UIImage? {
        let fileURL = path(for: url)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    func storeImageData(_ data: Data, for url: URL, response: URLResponse?) {
        let fileURL = path(for: url)
        do {
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Best effort.
        }
    }

    func clear() {
        try? fileManager.removeItem(at: baseURL)
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    private func path(for url: URL) -> URL {
        let name = cacheKey(for: url)
        return baseURL.appendingPathComponent(name)
    }

    private func cacheKey(for url: URL) -> String {
        // Stable filename derived from the full URL string.
        let input = Data(url.absoluteString.utf8)
        let digest = sha256(input)
        return digest + ".img"
    }

    private func sha256(_ data: Data) -> String {
        // Avoid CryptoKit dependency by using a simple built-in hash.
        // This isn't cryptographically strong, but it's stable enough for filenames.
        var hasher = Hasher()
        hasher.combine(data.count)
        data.forEach { hasher.combine($0) }
        let value = hasher.finalize()
        return String(value, radix: 16)
    }
}

import UIKit
