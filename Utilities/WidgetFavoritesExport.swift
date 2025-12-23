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
    // TODO: set to your real App Group (e.g. "group.com.macg4dave.CatFinderSwipe").
    static let appGroupId = "group.com.example.CatFinderSwipe"

    static func exportFavorites(modelContext: ModelContext) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            return
        }

        let fileURL = containerURL.appendingPathComponent("favorites.json")

        let favorites = (try? modelContext.fetch(FetchDescriptor<FavoriteCat>(sortBy: [SortDescriptor(\FavoriteCat.createdAt, order: .reverse)]))) ?? []

        struct WidgetFavorite: Codable {
            let id: String
            let imageURLString: String
            let createdAt: Date
        }

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
