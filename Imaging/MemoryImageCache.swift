import Foundation
import UIKit

/// A tiny NSCache-backed image cache.
///
/// Note: NSCache is already thread-safe; this remains a `final class` so it can be used
/// from the `ImagePipeline` actor without extra hops.
final class MemoryImageCache {
    private let cache = NSCache<NSURL, UIImage>()

    init() {
        // Roughly cap memory cache. Cost is estimated from pixel count.
        cache.totalCostLimit = 64 * 1024 * 1024 // 64 MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL, cost: image.memoryCost)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}

private extension UIImage {
    var memoryCost: Int {
        // Approx bytes = pixels * 4 (RGBA). Use size * scale to estimate pixels.
        let pixelsWide = size.width * scale
        let pixelsHigh = size.height * scale
        return Int(pixelsWide * pixelsHigh * 4)
    }
}
