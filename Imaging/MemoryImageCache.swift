import Foundation
import UIKit

/// A tiny NSCache-backed image cache.
///
/// Note: NSCache is already thread-safe; this remains a `final class` so it can be used
/// from the `ImagePipeline` actor without extra hops.
final class MemoryImageCache {
    private let cache = NSCache<NSString, UIImage>()

    init() {
        // Roughly cap memory cache. Cost is estimated from pixel count.
        cache.totalCostLimit = 64 * 1024 * 1024 // 64 MB

        // Additional guardrail to prevent too many distinct images piling up.
        cache.countLimit = 80
    }

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: image.memoryCost)
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
