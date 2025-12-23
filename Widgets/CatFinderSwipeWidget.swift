import WidgetKit
import SwiftUI

/// NOTE:
/// This file is intended to live in a WidgetKit Extension target.
///
/// This repo (as currently checked in) does not include an .xcodeproj, Info.plist,
/// or entitlements. You can still add this file now, then in Xcode:
/// 1) File > New > Target... > Widget Extension
/// 2) Move/add this file into the extension target
/// 3) Add an App Group to BOTH the app + extension
/// 4) Update `AppGroup.id` below
///
/// The widget reads a JSON export produced by the app (see `Utilities/WidgetFavoritesExport.swift`).

private enum AppGroup {
    // TODO: set to your real App Group (e.g. "group.com.macg4dave.CatFinderSwipe").
    static let id = "group.com.example.CatFinderSwipe"
}

struct WidgetFavorite: Codable {
    let id: String
    let imageURLString: String
    let createdAt: Date
}

struct FavoritesTimelineEntry: TimelineEntry {
    let date: Date
    let favorites: [WidgetFavorite]
}

struct FavoritesProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoritesTimelineEntry {
        FavoritesTimelineEntry(date: .now, favorites: [
            WidgetFavorite(id: "placeholder", imageURLString: "https://cataas.com/cat", createdAt: .now)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoritesTimelineEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesTimelineEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh periodically; the app can also call WidgetCenter.shared.reloadAllTimelines().
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> FavoritesTimelineEntry {
        let favorites = loadFavoritesFromAppGroup() ?? []
        return FavoritesTimelineEntry(date: .now, favorites: favorites)
    }

    private func loadFavoritesFromAppGroup() -> [WidgetFavorite]? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup.id) else {
            return nil
        }
        let fileURL = containerURL.appendingPathComponent("favorites.json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode([WidgetFavorite].self, from: data)
    }
}

struct RandomFavoriteWidgetView: View {
    let entry: FavoritesTimelineEntry

    var body: some View {
        ZStack {
            if let fav = entry.favorites.randomElement(), let url = URL(string: fav.imageURLString) {
                // Widgets cannot use your in-app ImagePipeline directly; use AsyncImage.
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.2)
                            .overlay(Image(systemName: "photo").font(.title))
                    case .empty:
                        Color.gray.opacity(0.15)
                    @unknown default:
                        Color.gray.opacity(0.15)
                    }
                }
            } else {
                Color.gray.opacity(0.15)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "heart")
                                .font(.title2)
                            Text("No favorites yet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    )
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct RandomFavoriteWidget: Widget {
    let kind = "CatFinderSwipe.RandomFavorite"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoritesProvider()) { entry in
            RandomFavoriteWidgetView(entry: entry)
        }
        .configurationDisplayName("Random Favorite")
        .description("Shows a random favorite cat.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CatFinderSwipeWidgetBundle: WidgetBundle {
    var body: some Widget {
        RandomFavoriteWidget()
    }
}
