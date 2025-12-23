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

    // Extra in-memory guard against re-queueing items while async fetches are in flight.
    private var pendingOrInDeckIDs: Set<String> = []

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
            pendingOrInDeckIDs.removeAll()

            let first = try await fetchNonSeenCard()
            pendingOrInDeckIDs.insert(first.id)

            let second = try await fetchNonSeenCard(excluding: first.id)
            pendingOrInDeckIDs.insert(second.id)

            current = first
            next = second
            backgroundColor = StableColor.color(for: UUID().uuidString)
            prefetchNextImage()
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
            if pendingOrInDeckIDs.contains(card.id) { continue }
            if store.isSeen(id: card.id) { continue }
            return card
        }
        return try await api.fetchNextCat()
    }

    func swipeLeft() {
        guard let current else { return }
        store.markSeen(current)
        pendingOrInDeckIDs.remove(current.id)
        advanceDeck()
    }

    func swipeRight() {
        guard let current else { return }
        store.addFavorite(current)
        store.markSeen(current)
        pendingOrInDeckIDs.remove(current.id)
        advanceDeck()
    }

    private func advanceDeck() {
        // Drop the visible next immediately so we don't render it underneath during transitions.
        let oldNext = next
        next = nil

        if let oldNext {
            current = oldNext
            backgroundColor = StableColor.color(for: UUID().uuidString)
        } else {
            current = nil
        }

        prefetchTask?.cancel()
        prefetchTask = nil

        Task {
            do {
                guard let current else { return }
                // Ensure the new current is tracked as "in deck".
                pendingOrInDeckIDs.insert(current.id)

                let newNext = try await fetchNonSeenCard(excluding: current.id)
                pendingOrInDeckIDs.insert(newNext.id)
                next = newNext
                prefetchNextImage()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    private func prefetchNextImage() {
        guard let next else { return }
        prefetchTask?.cancel()
        prefetchTask = Task {
            await ImagePipeline.shared.prefetch(next.imageURL)
        }
    }
}
