import Foundation
import UIKit
import ImageIO

/// Responsible for loading remote images with memory + disk caching.
///
/// This is intentionally UIKit-based (UIImage) because it's the most practical bridge
/// for SwiftUI image rendering and cache storage.
actor ImagePipeline {
    static let shared = ImagePipeline()

    private let memory: MemoryImageCache
    private let disk: DiskImageCache
    private let loader: ImageLoader

    init(
        memory: MemoryImageCache = .init(),
        disk: DiskImageCache = .init(),
        loader: ImageLoader = .init()
    ) {
        self.memory = memory
        self.disk = disk
        self.loader = loader
    }

    func image(for url: URL, maxPixelSize: Int? = nil) async throws -> UIImage {
        let key = cacheKeyString(for: url, maxPixelSize: maxPixelSize)

        if let cached = memory.image(forKey: key) {
            return cached
        }
        if let diskImage = await disk.loadImage(forKey: key) {
            memory.insert(diskImage, forKey: key)
            return diskImage
        }

        let (data, response) = try await loader.fetch(url: url)
        let image = try decodeUIImage(data: data, maxPixelSize: maxPixelSize)

        // Prefer storing a downsampled representation to keep disk + memory lean.
        let cachedData = encodeForCache(image: image, fallback: data)

        // Store even if server doesn't provide cache headers (our disk cache is app-owned).
        memory.insert(image, forKey: key)
        await disk.storeImageData(cachedData, forKey: key, response: response)
        return image
    }

    func prefetch(_ url: URL) async {
        _ = try? await image(for: url)
    }

    func prefetch(_ url: URL, maxPixelSize: Int?) async {
        _ = try? await image(for: url, maxPixelSize: maxPixelSize)
    }

    func clearMemory() {
        memory.removeAll()
    }

    func clearDisk() async {
        await disk.clear()
    }

    func clearAll() async {
        clearMemory()
        await clearDisk()
    }

    private func decodeUIImage(data: Data, maxPixelSize: Int?) throws -> UIImage {
        // Downsample to a caller-provided target (in pixels), with a sensible default.
        // This keeps textures sized appropriately for the current view.
        let resolvedMax: CGFloat
        if let maxPixelSize, maxPixelSize > 0 {
            resolvedMax = CGFloat(maxPixelSize)
        } else {
            resolvedMax = 2048
        }

        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            throw ImagePipelineError.invalidImageData
        }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: resolvedMax
        ]

        if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) {
            return UIImage(cgImage: cgImage)
        }

        // Fallback to UIKit decode if thumbnailing fails for any reason.
        if let image = UIImage(data: data) {
            return image
        }

        throw ImagePipelineError.invalidImageData
    }

    private func cacheKeyString(for url: URL, maxPixelSize: Int?) -> String {
        // Size varianting is critical: a small Favorites thumbnail should not poison the cache
        // for the full-size swipe card.
        if let maxPixelSize, maxPixelSize > 0 {
            return url.absoluteString + "|mps=\(maxPixelSize)"
        }
        return url.absoluteString
    }

    private func encodeForCache(image: UIImage, fallback: Data) -> Data {
        // JPEG is generally a good tradeoff for cat photos. If JPEG fails (e.g. alpha), fall back to PNG, else original.
        if let jpeg = image.jpegData(compressionQuality: 0.9) {
            return jpeg
        }
        if let png = image.pngData() {
            return png
        }
        return fallback
    }
}

enum ImagePipelineError: Error, LocalizedError {
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "The downloaded data wasn't a valid image."
        }
    }
}
