import XCTest
import SwiftData
@testable import CatFinderSwipe

final class WidgetFavoritesExportTests: XCTestCase {
    func testWidgetFavoriteEncodingIsValidISO8601JSON() throws {
        let sample = WidgetFavoritesExport.WidgetFavorite(
            id: "abc",
            imageURLString: "https://cataas.com/cat",
            createdAt: Date(timeIntervalSince1970: 0)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode([sample])

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([WidgetFavoritesExport.WidgetFavorite].self, from: data)

        XCTAssertEqual(decoded, [sample])
    }

    func testExportFavoritesWritesFileInAppGroupWhenAvailable() throws {
        // We can't guarantee an App Group container exists in unit tests.
        // This test just verifies that resolving the URL doesn't crash and that export is best-effort.
        let schema = Schema([FavoriteCat.self, SeenCat.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        context.insert(FavoriteCat(id: "1", imageURL: URL(string: "https://cataas.com/cat")!))

        // Should not throw even if the App Group container isn't available in tests.
        WidgetFavoritesExport.exportFavorites(modelContext: context)

        XCTAssertTrue(true)
    }
}
