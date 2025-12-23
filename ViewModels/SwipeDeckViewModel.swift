import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var current: CatCard?
    @Published private(set) var next: CatCard?

    @Published private(set) var backgroundColor: Color = StableColor.color(for: "initial")

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: CatAPIClientProtocol
    private var store: CatDecisionStore

    private var prefetchTask: Task<Void, Never>?

    init(api: CatAPIClientProtocol, store: CatDecisionStore) {
        self.api = api
        self.store = store
    }

    func replaceStore(_ store: CatDecisionStore) {
        self.store = store
    }

    func start() {
        Task { await ensureLoaded() }
    }

    func retry() {
        errorMessage = nil
        Task { await ensureLoaded(force: true) }
    }

    private func ensureLoaded(force: Bool = false) async {
        guard force || current == nil else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let first = try await fetchNonSeenCard()
            let second = try await fetchNonSeenCard(excluding: first.id)
            current = first
            next = second

            // Background to be a random solid colour on every swipe / initial load.
            backgroundColor = StableColor.color(for: UUID().uuidString)

            // Prefetch next image to keep swiping snappy.
            prefetchImagesForDeck()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func fetchNonSeenCard(excluding excludedId: String? = nil) async throws -> CatCard {
        var attempts = 0
        while attempts < 20 {
            attempts += 1
            let card = try await api.fetchNextCat()
            if let excludedId, card.id == excludedId { continue }
            if store.isSeen(id: card.id) { continue }
            return card
        }
        return try await api.fetchNextCat()
    }

    func swipeLeft() {
        guard let current else { return }
        store.markSeen(current)
        advanceDeck()
    }

    func swipeRight() {
        guard let current else { return }
        store.addFavorite(current)
        store.markSeen(current)
        advanceDeck()
    }

    private func advanceDeck() {
        current = next
        next = nil

        // Background to be a random solid colour on every swipe.
        backgroundColor = StableColor.color(for: UUID().uuidString)

        prefetchTask?.cancel()
        prefetchTask = nil

        Task {
            do {
                let newNext = try await fetchNonSeenCard(excluding: current?.id)
                next = newNext

                // Prefetch next image after the deck advances.
                prefetchImagesForDeck()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func prefetchImagesForDeck() {
        // Cancel any in-flight prefetch to prioritize the newest "next".
        prefetchTask?.cancel()
        prefetchTask = Task {
            if let current {
                // Warm the cache for the current card as well.
                await ImagePipeline.shared.prefetch(current.imageURL)
            }
            if let next {
                await ImagePipeline.shared.prefetch(next.imageURL)
            }
        }
    }
}
