import Foundation
import UIKit
import CryptoKit

/// A basic file-based image cache stored in the app's Caches directory.
actor DiskImageCache {
    private let baseURL: URL
    private let fileManager: FileManager
    private let maxDiskBytes: Int

    init(fileManager: FileManager = .default, maxDiskBytes: Int = 200 * 1024 * 1024) {
        self.fileManager = fileManager
        self.maxDiskBytes = maxDiskBytes
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.baseURL = caches.appendingPathComponent("CatFinderSwipeImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    func loadImage(forKey key: String) async -> UIImage? {
        let fileURL = path(forKey: key)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        // Touch the file to approximate LRU (newer modificationDate = more recently used).
        // Best effort: failures here should not break image loads.
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)

        return UIImage(data: data)
    }

    func storeImageData(_ data: Data, forKey key: String, response: URLResponse?) {
        let fileURL = path(forKey: key)
        do {
            try data.write(to: fileURL, options: [.atomic])

            // Best effort eviction after write.
            enforceSizeLimitIfNeeded()
        } catch {
            // Best effort.
        }
    }

    func clear() {
        try? fileManager.removeItem(at: baseURL)
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    private func enforceSizeLimitIfNeeded() {
        guard maxDiskBytes > 0 else { return }

        guard let urls = try? fileManager.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        struct Entry {
            let url: URL
            let size: Int
            let date: Date
        }

        var entries: [Entry] = []
        entries.reserveCapacity(urls.count)

        var total = 0
        for url in urls {
            guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]) else { continue }
            let size = values.fileSize ?? 0
            let date = values.contentModificationDate ?? .distantPast
            total += size
            entries.append(Entry(url: url, size: size, date: date))
        }

        guard total > maxDiskBytes else { return }

        // Delete oldest files first.
        entries.sort { $0.date < $1.date }
        for entry in entries {
            guard total > maxDiskBytes else { break }
            try? fileManager.removeItem(at: entry.url)
            total -= entry.size
        }
    }

    private func path(for url: URL) -> URL {
        // Backwards compatible with older on-disk keys.
        return path(forKey: url.absoluteString)
    }

    private func path(forKey key: String) -> URL {
        let name = cacheKey(forKey: key)
        return baseURL.appendingPathComponent(name)
    }

    private func cacheKey(forKey key: String) -> String {
        // Stable filename derived from a stable cache key string.
        // Use a stable, cross-launch digest (Hasher is intentionally randomized per-process).
        let digest = SHA256.hash(data: Data(key.utf8))
        let hex = digest.compactMap { String(format: "%02x", $0) }.joined()
        return hex + ".img"
    }
}
