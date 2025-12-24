import Foundation
import SwiftData
import WidgetKit

/// Exports favorites to a shared App Group container for WidgetKit.
///
/// This requires:
/// - adding an App Group capability to BOTH the main app target and the widget extension target
/// - setting the same identifier below in both targets
///
/// The widget reads `favorites.json` from the App Group container.

enum WidgetFavoritesExport {
    /// App Group identifier used for widget export.
    ///
    /// Keep this in sync with the Widget Extension's App Group entitlement.
    static let appGroupId = "group.com.example.CatFinderSwipe"

    enum SharedPaths {
        static func containerURL() -> URL? {
            FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)
        }

        static func favoritesJSONURL() -> URL? {
            containerURL()?.appendingPathComponent("favorites.json")
        }

        /// Optional: a shared image cache folder for the widget to read from.
        /// (Not wired up by default; safe to ignore.)
        static func sharedImageCacheDirectoryURL() -> URL? {
            containerURL()?.appendingPathComponent("ImageCache", isDirectory: true)
        }
    }

    /// Codable payload consumed by the widget.
    struct WidgetFavorite: Codable, Equatable {
        let id: String
        let imageURLString: String
        let createdAt: Date
    }

    static func exportFavorites(modelContext: ModelContext) {
        guard let fileURL = SharedPaths.favoritesJSONURL() else {
            return
        }

        let favorites = (try? modelContext.fetch(
            FetchDescriptor<FavoriteCat>(sortBy: [SortDescriptor(\FavoriteCat.createdAt, order: .reverse)])
        )) ?? []

        let payload = favorites.map { WidgetFavorite(id: $0.id, imageURLString: $0.imageURLString, createdAt: $0.createdAt) }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(payload)
            try data.write(to: fileURL, options: [.atomic])

            // Nudge widgets to refresh.
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // Best effort export.
        }
    }
}
