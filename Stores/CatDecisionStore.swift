import Foundation
import SwiftData

@MainActor
final class CatDecisionStore {
    private let modelContext: ModelContext

    // Cache to make repeat checks fast (Milestone 2).
    private var seenIDCache: Set<String> = []
    private var didPreloadCaches: Bool = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Load caches from SwiftData. Safe to call multiple times.
    func preloadCaches() {
        guard !didPreloadCaches else { return }
        didPreloadCaches = true

        if let seen = try? modelContext.fetch(FetchDescriptor<SeenCat>()) {
            seenIDCache = Set(seen.map { $0.id })
        }
    }

    func isSeen(id: String) -> Bool {
        preloadCaches()
        return seenIDCache.contains(id)
    }

    func isFavorite(id: String) -> Bool {
        (try? modelContext.fetchCount(FetchDescriptor<FavoriteCat>(predicate: #Predicate { $0.id == id }))) ?? 0 > 0
    }

    func markSeen(_ card: CatCard) {
        preloadCaches()
        guard !seenIDCache.contains(card.id) else { return }
        modelContext.insert(SeenCat(id: card.id, imageURL: card.imageURL))
        seenIDCache.insert(card.id)
    }

    func addFavorite(_ card: CatCard) {
        guard !isFavorite(id: card.id) else { return }
        modelContext.insert(FavoriteCat(id: card.id, imageURL: card.imageURL))
    }

    func removeFavorite(id: String) {
        let descriptor = FetchDescriptor<FavoriteCat>(predicate: #Predicate { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }
    }

    /// Undo support: remove a SeenCat record for this ID.
    func unmarkSeen(id: String) {
        preloadCaches()

        let descriptor = FetchDescriptor<SeenCat>(predicate: #Predicate { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }

        // Keep cache consistent even if the record wasn't found.
        seenIDCache.remove(id)
    }

    /// Undo support: best-effort removal if it exists.
    func removeFavoriteIfPresent(id: String) {
        removeFavorite(id: id)
    }

    func clearAll() {
        if let favorites = try? modelContext.fetch(FetchDescriptor<FavoriteCat>()) {
            favorites.forEach { modelContext.delete($0) }
        }
        if let seen = try? modelContext.fetch(FetchDescriptor<SeenCat>()) {
            seen.forEach { modelContext.delete($0) }
        }

        // Keep caches consistent.
        seenIDCache.removeAll()
        didPreloadCaches = true
    }
}
