import Foundation
import UIKit

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

    func image(for url: URL) async throws -> UIImage {
        if let cached = memory.image(for: url) {
            return cached
        }
        if let diskImage = await disk.loadImage(for: url) {
            memory.insert(diskImage, for: url)
            return diskImage
        }

        let (data, response) = try await loader.fetch(url: url)
        let image = try decodeUIImage(data: data)

        // Store even if server doesn't provide cache headers (our disk cache is app-owned).
        memory.insert(image, for: url)
        await disk.storeImageData(data, for: url, response: response)
        return image
    }

    func prefetch(_ url: URL) async {
        _ = try? await image(for: url)
    }

    func clearMemory() {
        memory.removeAll()
    }

    func clearDisk() async {
        await disk.clear()
    }

    private func decodeUIImage(data: Data) throws -> UIImage {
        if let image = UIImage(data: data) {
            return image
        }
        throw ImagePipelineError.invalidImageData
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
