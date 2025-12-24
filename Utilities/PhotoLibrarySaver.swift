import Foundation
import Photos
import UIKit

enum PhotoLibrarySaverError: Error, LocalizedError {
    case notAuthorized
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Photo Library access is not allowed. Please enable it in Settings."
        case .saveFailed:
            return "Couldn’t save the image to Photos."
        }
    }
}

/// Saves images to the user's Photos library.
///
/// Requires `NSPhotoLibraryAddUsageDescription` in Info.plist.
@MainActor
final class PhotoLibrarySaver {
    static let shared = PhotoLibrarySaver()

    private init() {}

    func saveImage(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoLibrarySaverError.notAuthorized
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: PhotoLibrarySaverError.saveFailed)
                }
            }
        }
    }
}
