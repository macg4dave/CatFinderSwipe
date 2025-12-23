import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var current: CatCard?
    @Published private(set) var next: CatCard?

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

    func backgroundColor(for card: CatCard) -> Color {
        StableColor.color(for: card.id)
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

            prefetchNextImage()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func fetchNonSeenCard(excluding excludedId: String? = nil) async throws -> CatCard {
        var attempts = 0
        while attempts < 10 {
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

        prefetchNextImage()

        Task {
            do {
                let newNext = try await fetchNonSeenCard(excluding: current?.id)
                next = newNext
                prefetchNextImage()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func prefetchNextImage() {
        prefetchTask?.cancel()
        guard let url = next?.imageURL else { return }

        prefetchTask = Task {
            await ImagePipeline.shared.prefetch(url)
        }
    }
}
